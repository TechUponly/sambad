# Fix: Port 5050 Already in Use

## Quick Fix

The server is hanging because port 5050 is already in use. Here's how to fix it:

### Option 1: Kill the Existing Process

In your terminal (where the server is running), press **Ctrl+C** to stop it.

Then run:
```bash
lsof -ti:5050 | xargs kill -9
```

Then start the server again:
```bash
./START_SERVER.sh
```

### Option 2: Use a Different Port

Edit `START_SERVER.sh` and change:
```bash
export ADMIN_PORT=5051  # or any other port
```

Then update Chrome to: `http://localhost:5051/`

### Option 3: Check What's Using Port 5050

```bash
lsof -i :5050
```

This will show you what process is using the port.

---

**After killing the process, the server should start normally and you'll see:**
```
✅ Admin backend listening on port 5050
🌐 Dashboard: http://localhost:5050/
```

Then refresh Chrome!
