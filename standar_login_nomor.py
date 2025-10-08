import asyncio
from pyrogram import Client, errors

api_id = 20233450
api_hash = "f32bc9aff34316b554bce7796e4c4738"
session_string = ""

async def main():
    app = Client('my_account', api_id=api_id, api_hash=api_hash, session_string=session_string)
    await app.connect()
    session_string = await app.export_session_string()
    print("Session String:", session_string)
    me = await app.get_me()
    print(me)
    await app.disconnect()

if __name__ == "__main__":
    asyncio.run(main())

