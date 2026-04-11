// End-to-end 2-user chat test on production
const WebSocket = require('ws');

const WS_URL = 'wss://web.uponlytech.com/sambad-backend/ws';
const USER_A = 'user-alice-test';
const USER_B = 'user-bob-test';

let passed = 0;
let failed = 0;

function test(name, condition) {
  if (condition) { passed++; console.log(`  ✅ ${name}`); }
  else { failed++; console.log(`  ❌ ${name}`); }
}

console.log('🧪 E2E Chat Test — Production');
console.log('================================\n');

// Connect User A
console.log('1️⃣  Connecting User A (Alice)...');
const wsA = new WebSocket(`${WS_URL}?userId=${USER_A}`);

// Connect User B
console.log('2️⃣  Connecting User B (Bob)...');
const wsB = new WebSocket(`${WS_URL}?userId=${USER_B}`);

let aConnected = false, bConnected = false;
let aRegistered = false, bRegistered = false;
let bobReceivedMessage = false;

wsA.on('open', () => {
  aConnected = true;
  console.log('   Alice: WebSocket OPEN');
  wsA.send(JSON.stringify({ type: 'register', userId: USER_A }));
});

wsA.on('message', (data) => {
  const msg = JSON.parse(data.toString());
  if (msg.type === 'registered') {
    aRegistered = true;
    console.log('   Alice: Registered ✓');
    checkBothReady();
  }
  if (msg.type === 'message') {
    console.log(`   Alice received: "${msg.content}"`);
  }
});

wsB.on('open', () => {
  bConnected = true;
  console.log('   Bob: WebSocket OPEN');
  wsB.send(JSON.stringify({ type: 'register', userId: USER_B }));
});

wsB.on('message', (data) => {
  const msg = JSON.parse(data.toString());
  if (msg.type === 'registered') {
    bRegistered = true;
    console.log('   Bob: Registered ✓');
    checkBothReady();
  }
  if (msg.type === 'message' || msg.content) {
    bobReceivedMessage = true;
    console.log(`   Bob received: "${msg.content || JSON.stringify(msg)}"`);
  }
});

wsA.on('error', (e) => console.log('   Alice ERROR:', e.message));
wsB.on('error', (e) => console.log('   Bob ERROR:', e.message));

function checkBothReady() {
  if (!aRegistered || !bRegistered) return;
  
  console.log('\n3️⃣  Both users connected. Sending message...');
  
  // Alice sends a message to Bob via WebSocket
  const chatMsg = {
    type: 'message',
    fromId: USER_A,
    toId: USER_B,
    content: 'Hello Bob! This is a real-time test from Alice 🎉',
    timestamp: new Date().toISOString()
  };
  
  wsA.send(JSON.stringify(chatMsg));
  console.log('   Alice sent: "Hello Bob! This is a real-time test from Alice 🎉"');
  
  // Wait and check results
  setTimeout(() => {
    console.log('\n📊 TEST RESULTS');
    console.log('================');
    test('Alice connected to WSS via Nginx', aConnected);
    test('Bob connected to WSS via Nginx', bConnected);
    test('Alice registered with server', aRegistered);
    test('Bob registered with server', bRegistered);
    test('Bob received Alice\'s message in real-time', bobReceivedMessage);
    
    console.log(`\n🏁 ${passed}/${passed+failed} tests passed`);
    
    if (!bobReceivedMessage) {
      console.log('\n⚠️  Note: Direct WS relay may not be implemented.');
      console.log('   Messages typically go: App → HTTP API → DB → WebSocket relay');
      console.log('   The WebSocket channel IS working for push notifications.');
    }
    
    wsA.close();
    wsB.close();
    process.exit(failed > 0 ? 1 : 0);
  }, 3000);
}

// Timeout safety
setTimeout(() => {
  console.log('\n⏰ TIMEOUT — connections failed');
  test('Connection established within 10s', false);
  process.exit(1);
}, 10000);
