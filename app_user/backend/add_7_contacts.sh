#!/bin/bash
# Script to add 7 dummy contacts and verify on both sides

BASE_URL="http://localhost:4000"

echo "🧪 Creating 7 dummy contacts..."
echo ""

# Step 1: Create main user
echo "Step 1: Creating main user..."
MAIN_RESP=$(curl -s -X POST "$BASE_URL/api/users/login" \
  -H "Content-Type: application/json" \
  -d '{"mobileNumber":"9999999999","countryCode":"+91"}')

MAIN_ID=$(echo "$MAIN_RESP" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('user', {}).get('id', ''))" 2>/dev/null)

if [ -z "$MAIN_ID" ]; then
  echo "❌ Failed to create main user"
  exit 1
fi

echo "✅ Main user ID: $MAIN_ID"
echo ""

# Step 2: Create 7 contact users
echo "Step 2: Creating 7 contact users..."
CONTACT_IDS=""
for i in 1 2 3 4 5 6 7; do
  USER_RESP=$(curl -s -X POST "$BASE_URL/api/users/login" \
    -H "Content-Type: application/json" \
    -d "{\"mobileNumber\":\"888888888$i\",\"countryCode\":\"+91\"}")
  
  USER_ID=$(echo "$USER_RESP" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('user', {}).get('id', ''))" 2>/dev/null)
  
  if [ -n "$USER_ID" ]; then
    CONTACT_IDS="$CONTACT_IDS $USER_ID"
    echo "✅ Contact user $i: $USER_ID"
  else
    echo "⚠️  Contact user $i failed"
  fi
  sleep 0.2
done

echo ""
echo "Step 3: Adding 7 contacts..."
SUCCESS=0
for i in 1 2 3 4 5 6 7; do
  CID=$(echo $CONTACT_IDS | cut -d' ' -f$i)
  if [ -n "$CID" ]; then
    RESP=$(curl -s -X POST "$BASE_URL/api/contacts" \
      -H "Content-Type: application/json" \
      -d "{\"userId\":\"$MAIN_ID\",\"contactUserId\":\"$CID\"}")
    
    if echo "$RESP" | python3 -c "import sys, json; d=json.load(sys.stdin); exit(0 if 'message' in d or 'contact' in d else 1)" 2>/dev/null; then
      SUCCESS=$((SUCCESS+1))
      echo "✅ Contact $i added"
    else
      echo "⚠️  Contact $i may already exist"
    fi
    sleep 0.2
  fi
done

echo ""
echo "📊 Added $SUCCESS/7 contacts successfully"
echo ""

# Step 4: Verify in database
echo "Step 4: Verifying in database..."
node -e "
const db = require('better-sqlite3')('sambad_user.db');
const count = db.prepare('SELECT COUNT(*) as c FROM contacts').get().c;
console.log(\`Database contacts: \${count}\`);
if (count > 0) {
  const recent = db.prepare('SELECT u1.username as u, u2.username as c FROM contacts ct JOIN users u1 ON ct.user_id = u1.id JOIN users u2 ON ct.contact_user_id = u2.id ORDER BY ct.created_at DESC LIMIT 7').all();
  recent.forEach((r, i) => console.log(\`  \${i+1}. \${r.u} → \${r.c}\`));
}
db.close();
" 2>&1

echo ""
echo "Step 5: Verifying via User App API..."
USER_API=$(curl -s -X GET "$BASE_URL/api/contacts")
echo "$USER_API" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(f'User App API - Total: {len(d)} contacts')
for i, c in enumerate(d[:7], 1):
    user = c.get('user', {}).get('username', 'N/A')
    contact = c.get('contact_user', {}).get('username', 'N/A')
    print(f'  {i}. {user} → {contact}')
" 2>/dev/null

echo ""
echo "Step 6: Verifying via Admin API..."
TOKEN=$(curl -s -X POST "$BASE_URL/api/admin/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"7718811069","password":"Taksh@060921"}' | \
  python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('token', ''))" 2>/dev/null)

if [ -n "$TOKEN" ]; then
  ADMIN_CONTACTS=$(curl -s -X GET "$BASE_URL/api/admin/contacts" \
    -H "Authorization: Bearer $TOKEN")
  
  echo "$ADMIN_CONTACTS" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(f'Admin API - Total: {len(d)} contacts')
for i, c in enumerate(d[:7], 1):
    user = c.get('user', {}).get('username', 'N/A')
    contact = c.get('contact_user', {}).get('username', 'N/A')
    print(f'  {i}. {user} → {contact}')
" 2>/dev/null
  
  ANALYTICS=$(curl -s -X GET "$BASE_URL/api/admin/analytics" \
    -H "Authorization: Bearer $TOKEN")
  
  echo "$ANALYTICS" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(f'Admin Analytics - Total Contacts: {d.get(\"totalContacts\", 0)}')
print(f'Admin Analytics - Total Users: {d.get(\"totalUsers\", 0)}')
" 2>/dev/null
fi

echo ""
echo "✅ Verification complete! All 7 contacts should be visible on both sides."
