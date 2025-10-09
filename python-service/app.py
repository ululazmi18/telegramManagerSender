"""
Flask Alternative for Pyrogram Service
Use this if FastAPI has compatibility issues with Python 3.12
"""
from flask import Flask, request, jsonify
from flask_cors import CORS
from pyrogram import Client, errors
import asyncio
import hashlib
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('telegram_service.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Dictionary to store ongoing sessions for multi-step authentication
authentication_sessions = {}

# Helper to run async functions
def run_async(coro):
    """Run async coroutine in sync context"""
    try:
        loop = asyncio.get_event_loop()
        if loop.is_closed():
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
    except RuntimeError:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
    
    try:
        return loop.run_until_complete(coro)
    except Exception as e:
        logger.error(f"Error in run_async: {e}")
        raise

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    logger.info("Health check called")
    return jsonify({"status": "healthy", "service": "python-pyrogram-service-flask"})

@app.route('/export_session', methods=['POST'])
def export_session():
    """Export session string for a given phone number - Standard approach"""
    data = request.json
    api_id = data.get("api_id")
    api_hash = data.get("api_hash")
    phone_number = data.get("phone_number")
    
    if not all([api_id, api_hash, phone_number]):
        return jsonify({"success": False, "error": "api_id, api_hash, and phone_number are required"}), 400
    
    try:
        async def _export():
            # Use in_memory=True for temporary session like in standard
            client = Client('temp_session', api_id=api_id, api_hash=api_hash, in_memory=True)
            await client.connect()
            sent_code = await client.send_code(phone_number)
            await client.disconnect()
            
            # Create session ID for tracking
            session_id = f"auth_{hashlib.md5((phone_number + str(sent_code.phone_code_hash)).encode()).hexdigest()}"
            authentication_sessions[session_id] = {
                "api_id": api_id,
                "api_hash": api_hash,
                "phone_number": phone_number,
                "phone_code_hash": sent_code.phone_code_hash
            }
            
            logger.info(f"Code sent to {phone_number}, session_id: {session_id}")
            
            return {
                "success": True,
                "session_id": session_id,
                "message": f"Code sent to {phone_number}. Please provide the code to complete authentication.",
                "phone_code_hash": sent_code.phone_code_hash
            }
        
        result = run_async(_export())
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error in export_session: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/complete_auth', methods=['POST'])
def complete_auth():
    """Complete the authentication process with the code received - Standard approach"""
    data = request.json
    session_id = data.get("session_id")
    phone_code = data.get("phone_code")
    password = data.get("password")
    
    if not all([session_id, phone_code]):
        return jsonify({"success": False, "error": "session_id and phone_code are required"}), 400
    
    logger.info(f"Complete auth request - session_id: {session_id}")
    
    if session_id not in authentication_sessions:
        logger.error(f"Invalid session ID: {session_id}")
        return jsonify({"success": False, "error": "Invalid session ID"}), 400
    
    auth_session = authentication_sessions[session_id]
    
    try:
        async def _complete():
            # Use in_memory=True like in standard approach
            client = Client(
                'temp_auth_session',
                api_id=auth_session["api_id"],
                api_hash=auth_session["api_hash"],
                in_memory=True
            )
            await client.connect()
            
            try:
                # Standard sign_in approach
                await client.sign_in(
                    phone_number=auth_session["phone_number"],
                    phone_code_hash=auth_session["phone_code_hash"],
                    phone_code=phone_code
                )
                logger.info("Sign in successful")
            except Exception as e:
                from pyrogram import errors
                if isinstance(e, errors.SessionPasswordNeeded):
                    if not password:
                        await client.disconnect()
                        return {"success": False, "error": "PASSWORD_REQUIRED", "requires_password": True}
                    try:
                        await client.check_password(password)
                        logger.info("Password verification successful")
                    except errors.BadRequest:
                        await client.disconnect()
                        return {"success": False, "error": "BAD_PASSWORD"}
                elif isinstance(e, errors.PhoneCodeInvalid):
                    await client.disconnect()
                    return {"success": False, "error": "PHONE_CODE_INVALID"}
                elif isinstance(e, errors.PhoneCodeExpired):
                    await client.disconnect()
                    return {"success": False, "error": "PHONE_CODE_EXPIRED"}
                else:
                    await client.disconnect()
                    raise e
            
            # Export session string like in standard
            session_string = await client.export_session_string()
            
            # Get user info like in standard
            me = await client.get_me()
            
            await client.disconnect()
            
            # Clean up session from memory
            del authentication_sessions[session_id]
            
            return {
                "success": True,
                "session_string": session_string,
                "user_info": {
                    "id": me.id,
                    "first_name": me.first_name,
                    "last_name": me.last_name,
                    "username": me.username,
                    "phone_number": me.phone_number,
                    "is_premium": me.is_premium
                }
            }
        
        result = run_async(_complete())
        return jsonify(result)
    except Exception as e:
        error_msg = str(e)
        logger.error(f"Complete auth error: {error_msg}")
        
        # Clean up session on error
        if session_id in authentication_sessions:
            del authentication_sessions[session_id]
        
        return jsonify({"success": False, "error": error_msg}), 400

@app.route('/validate_session', methods=['POST'])
def validate_session():
    """Validate an existing session string - Standard approach"""
    data = request.json
    session_string = data.get("session_string")
    
    if not session_string:
        return jsonify({"success": False, "error": "session_string is required"}), 400
    
    try:
        async def _validate():
            # Use session string like in updated standard approach
            client = Client('validation_session', session_string=session_string)
            await client.start()
            
            # Get user info like in standard
            me = await client.get_me()
            
            await client.stop()
            
            return {
                "success": True,
                "valid": True,
                "user_info": {
                    "id": me.id,
                    "first_name": me.first_name,
                    "last_name": me.last_name,
                    "username": me.username,
                    "phone_number": me.phone_number,
                    "is_premium": me.is_premium
                }
            }
        
        result = run_async(_validate())
        return jsonify(result)
    except Exception as e:
        logger.error(f"Session validation error: {str(e)}")
        return jsonify({
            "success": True,
            "valid": False,
            "error": str(e)
        }), 200

@app.route('/send_message', methods=['POST'])
def send_message():
    """Send a comment to a channel post"""
    data = request.json
    session_string = data.get("session_string")
    chat_id = data.get("chat_id")
    message_type = data.get("message_type")
    file_path = data.get("file_path")
    caption = data.get("caption", "")
    
    logger.info(f"📨 NEW REQUEST - Send Message to Channel: {chat_id}")
    
    if not session_string or not chat_id:
        return jsonify({"success": False, "error": "session_string and chat_id are required"}), 400
    
    try:
        async def _send():
            client = Client("temp_client", session_string=session_string)
            await client.start()
            
            reply_text = caption if caption else ""
            message_id_to_comment = None
            comment_found = False
            
            # Check for duplicate comments - following standard approach
            try:
                async for message in client.get_chat_history(chat_id=chat_id, limit=30):
                    try:
                        async for comment in client.get_discussion_replies(chat_id=chat_id, message_id=message.id, limit=10):
                            comment_text = comment.text if comment.text else comment.caption
                            if comment_text and reply_text:
                                if reply_text.strip().lower() in comment_text.strip().lower():
                                    comment_found = True
                                    break
                    except errors.exceptions.bad_request_400.MsgIdInvalid:
                        continue
                    
                    if not comment_found:
                        message_id_to_comment = message.id
                        break
            except errors.exceptions.bad_request_400.UsernameNotOccupied:
                await client.stop()
                return {
                    "success": False,
                    "error": "Username not occupied or channel not found"
                }
            
            if comment_found:
                await client.stop()
                return {
                    "success": True,
                    "skipped": True,
                    "reason": "Duplicate comment detected"
                }
            
            if not message_id_to_comment:
                await client.stop()
                raise Exception("No suitable message found to comment on")
            
            discussion_message = await client.get_discussion_message(chat_id=chat_id, message_id=message_id_to_comment)
            
            # Send comment
            if file_path and message_type in ["photo", "video"]:
                import os
                ext = os.path.splitext(file_path)[1].lower()
                if message_type == "photo" or ext in [".png", ".jpg", ".jpeg", ".gif"]:
                    result = await discussion_message.reply_photo(photo=file_path, caption=reply_text)
                else:
                    result = await discussion_message.reply_video(video=file_path, caption=reply_text)
            else:
                from pyrogram.enums import ParseMode
                result = await discussion_message.reply(reply_text, parse_mode=ParseMode.MARKDOWN)
            
            await client.stop()
            
            return {
                "success": True,
                "skipped": False,
                "data": {
                    "message_id": result.id,
                    "chat_id": result.chat.id,
                    "date": result.date.isoformat() if result.date else None,
                    "parent_message_id": message_id_to_comment
                }
            }
        
        result = run_async(_send())
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/get_me', methods=['POST'])
def get_me():
    """Get information about the current user - Standard approach"""
    data = request.json
    session_string = data.get("session_string")
    
    if not session_string:
        return jsonify({"success": False, "error": "session_string is required"}), 400
    
    try:
        async def _get_me():
            # Use updated standard approach with start/stop
            client = Client("user_info_session", session_string=session_string)
            await client.start()
            me = await client.get_me()
            await client.stop()
            
            return {
                "success": True,
                "user_info": {
                    "id": me.id,
                    "first_name": me.first_name,
                    "last_name": me.last_name,
                    "username": me.username,
                    "phone_number": me.phone_number,
                    "is_premium": me.is_premium,
                }
            }
        
        result = run_async(_get_me())
        return jsonify(result)
    except Exception as e:
        logger.error(f"Get user info error: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

if __name__ == "__main__":
    print("🚀 Starting Flask Pyrogram Service on port 8000...")
    app.run(host="0.0.0.0", port=8000, debug=False)
