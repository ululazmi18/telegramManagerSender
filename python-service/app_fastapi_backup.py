"""
Flask Alternative for Pyrogram Service
Use this if FastAPI has compatibility issues with Python 3.12
"""
from flask import Flask, request, jsonify
from flask_cors import CORS
from pyrogram import Client
from pyrogram.types import Message
import asyncio
import hashlib
import logging
from datetime import datetime

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
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    try:
        return loop.run_until_complete(coro)
    finally:
        loop.close()

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    logger.info("Health check called")
    return jsonify({"status": "healthy", "service": "python-pyrogram-service-flask"})

@app.route('/export_session', methods=['POST'])
def export_session():
    """Export session string for a given phone number"""
    data = request.json
    api_id = data.get("api_id")
    api_hash = data.get("api_hash")
    phone_number = data.get("phone_number")
    
    try:
        async def _export():
            session_name = f"temp_{hashlib.md5(phone_number.encode()).hexdigest()}"
            client = Client(session_name, api_id=api_id, api_hash=api_hash)
            await client.connect()
            sent_code = await client.send_code(phone_number)
            
            session_id = f"auth_{hashlib.md5((phone_number + str(sent_code.phone_code_hash)).encode()).hexdigest()}"
            authentication_sessions[session_id] = {
                "client": client,
                "phone_number": phone_number,
                "phone_code_hash": sent_code.phone_code_hash
            }
            
            return {
                "success": True,
                "session_id": session_id,
                "message": f"Code sent to {phone_number}. Please provide the code to complete authentication.",
                "phone_code_hash": sent_code.phone_code_hash
            }
        
        result = run_async(_export())
        return jsonify(result)
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/complete_auth', methods=['POST'])
def complete_auth():
    """Complete the authentication process with the code received"""
    data = request.json
    session_id = data.get("session_id")
    phone_code = data.get("phone_code")
    password = data.get("password")
    
    if session_id not in authentication_sessions:
        return jsonify({"success": False, "error": "Invalid session ID"}), 400
    
    auth_session = authentication_sessions[session_id]
    client = auth_session["client"]
    
    try:
        async def _complete():
            try:
                await client.sign_in(auth_session["phone_number"], auth_session["phone_code_hash"], phone_code)
            except Exception as e:
                from pyrogram import errors
                if isinstance(e, errors.SessionPasswordNeeded):
                    if not password:
                        raise Exception("PASSWORD_REQUIRED")
                    try:
                        await client.check_password(password)
                    except:
                        raise Exception("BAD_PASSWORD")
                else:
                    raise e
            
            session_string = await client.export_session_string()
            del authentication_sessions[session_id]
            await client.disconnect()
            
            return {"success": True, "session_string": session_string}
        
        result = run_async(_complete())
        return jsonify(result)
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

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
            
            # Check for duplicate comments
            async for message in client.get_chat_history(chat_id=chat_id, limit=30):
                try:
                    async for comment in client.get_discussion_replies(chat_id=chat_id, message_id=message.id, limit=10):
                        comment_text = comment.text if comment.text else comment.caption
                        if comment_text and reply_text:
                            if reply_text.strip().lower() in comment_text.strip().lower():
                                comment_found = True
                                break
                    
                    if not comment_found:
                        message_id_to_comment = message.id
                        break
                except:
                    continue
            
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

@app.route('/get_me', methods=['GET'])
def get_me():
    """Get information about the current user"""
    session_string = request.args.get("session_string")
    
    try:
        async def _get_me():
            client = Client("temp_client", session_string=session_string)
            await client.start()
            me = await client.get_me()
            await client.stop()
            
            return {
                "success": True,
                "data": {
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
        return jsonify({"success": False, "error": str(e)}), 500

if __name__ == "__main__":
    print("🚀 Starting Flask Pyrogram Service on port 8000...")
    app.run(host="0.0.0.0", port=8000, debug=False)
