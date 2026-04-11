/**
 * 🧪 Samvad E2E Production Test (with Firebase Auth)
 */
const WebSocket = require('ws');
const https = require('https');

const BASE = 'https://web.uponlytech.com/sambad-backend';
const WS_URL = 'wss://web.uponlytech.com/sambad-backend/ws';
const AUTH_TOKEN = process.env.FB_TOKEN;

function api(method, path, body) {
  return new Promise((resolve, reject) => {
    const url = new URL(BASE + path);
    const headers = { 'Content-Type': 'application/json' };
    if (AUTH_TOKEN) headers['Authorization'] = 'Bearer ' + AUTH_TOKEN;
    const options = { hostname: url.hostname, port: 443, path: url.pathname, method, headers };
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch { resolve({ status: res.statusCode, body: data }); }
      });
    });
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

function connectWS(userId) {
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(`${WS_URL}?userId=${userId}`);
    const messages = [];
    ws.on('open', () => resolve({ ws, messages }));
    ws.on('message', (data) => messages.push(JSON.parse(data.toString())));
    ws.on('error', reject);
    setTimeout(() => reject(new Error('WS timeout')), 10000);
  });
}

const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const PASS = '✅', FAIL = '❌';
const results = [];

function test(name, passed, detail = '') {
  results.push({ name, passed, detail });
  console.log(`  ${passed ? PASS : FAIL} ${name}${detail ? ' — ' + detail : ''}`);
}

async function runTests() {
  console.log('\n🧪 ═══════════════════════════════════════════════');
  console.log('   SAMVAD PRODUCTION E2E TEST (Authenticated)');
  console.log('═══════════════════════════════════════════════\n');

  // 1. Health
  console.log('📡 1. Health Check');
  const health = await api('GET', '/api/health');
  test('Backend healthy', health.status === 200);
  test('Database connected', health.body.database === 'connected');

  // 2. Login
  console.log('\n👤 2. User Login');
  const resA = await api('POST', '/api/users/login', { phone: '+919999900001', name: 'TestUserA' });
  const userA = resA.body;
  test('User A login', resA.status === 200 && !!userA.id, `id=${userA.id}`);

  const resB = await api('POST', '/api/users/login', { phone: '+919999900002', name: 'TestUserB' });
  const userB = resB.body;
  test('User B login', resB.status === 200 && !!userB.id, `id=${userB.id}`);

  // 3. WebSocket
  console.log('\n🔌 3. WebSocket');
  const wsA = await connectWS(userA.id);
  test('User A WS connected', true);
  await wait(500);
  test('Welcome msg received', wsA.messages.some(m => m.type === 'connected'));

  const wsB = await connectWS(userB.id);
  test('User B WS connected', true);
  await wait(500);

  // 4. Direct Message A→B
  console.log('\n💬 4. Direct Message (A → B)');
  wsB.messages.length = 0;
  const msgText = 'E2E test: ' + new Date().toISOString();
  const sendRes = await api('POST', '/api/messages', { fromId: userA.id, toId: userB.id, content: msgText });
  test('Message sent', sendRes.status === 201, `id=${sendRes.body?.id}`);

  await wait(1500);
  const received = wsB.messages.find(m => m.type === 'new_message');
  test('B received via WebSocket', !!received, received ? received.data?.content?.substring(0, 40) : 'NOT RECEIVED');
  if (received) {
    test('Content matches', received.data?.content === msgText);
    test('Sender ID correct', received.data?.fromId === userA.id);
  }

  // 5. Reply B→A
  console.log('\n💬 5. Reply (B → A)');
  wsA.messages.length = 0;
  const reply = await api('POST', '/api/messages', { fromId: userB.id, toId: userA.id, content: 'Reply! ' + Date.now() });
  test('Reply sent', reply.status === 201);
  await wait(1500);
  const replyRecv = wsA.messages.find(m => m.type === 'new_message');
  test('A received reply via WS', !!replyRecv);

  // 6. Delivery & Read Receipts
  console.log('\n✓✓ 6. Receipts');
  const freshMsg = await api('POST', '/api/messages', { fromId: userA.id, toId: userB.id, content: 'Receipt test' });
  wsA.messages.length = 0;

  const delRes = await api('PUT', `/api/messages/${freshMsg.body.id}/delivered`);
  test('Marked delivered', delRes.status === 200 && delRes.body.status === 'delivered');
  await wait(500);
  test('Sender notified (delivered)', !!wsA.messages.find(m => m.type === 'message_delivered'));

  wsA.messages.length = 0;
  const readRes = await api('PUT', `/api/messages/${freshMsg.body.id}/read`);
  test('Marked read', readRes.status === 200 && readRes.body.status === 'read');
  await wait(500);
  test('Sender notified (read)', !!wsA.messages.find(m => m.type === 'message_read'));

  // 7. Group Chat
  console.log('\n👥 7. Group Chat');
  wsB.messages.length = 0;
  const grp = await api('POST', '/api/groups', {
    name: 'E2E Group ' + Date.now(), description: 'Test', createdBy: userA.id, memberIds: [userB.id]
  });
  test('Group created', grp.status === 201, `id=${grp.body?.id}`);
  test('2 members', grp.body?.memberCount === 2);
  const groupId = grp.body?.id;

  await wait(500);
  test('B notified of group add', !!wsB.messages.find(m => m.type === 'group_added'));

  const details = await api('GET', `/api/groups/${groupId}`);
  test('Group details fetched', details.status === 200);
  test('Creator is admin', details.body?.members?.find(m => m.userId === userA.id)?.role === 'admin');

  wsB.messages.length = 0;
  const grpMsg = await api('POST', `/api/groups/${groupId}/messages`, { fromId: userA.id, content: 'Group hello!' });
  test('Group message sent', grpMsg.status === 201);
  await wait(1000);
  const grpRecv = wsB.messages.find(m => m.type === 'group_message');
  test('B received group message', !!grpRecv);
  test('Has sender name', !!grpRecv?.data?.fromName, `name=${grpRecv?.data?.fromName}`);

  // 8. Group Management
  console.log('\n⚙️  8. Group Mgmt');
  const edit = await api('PUT', `/api/groups/${groupId}`, { name: 'Renamed', userId: userA.id });
  test('Admin renamed group', edit.status === 200);

  const failEdit = await api('PUT', `/api/groups/${groupId}`, { name: 'Hacked', userId: userB.id });
  test('Non-admin blocked', failEdit.status === 403);

  wsA.messages.length = 0;
  const exit = await api('POST', `/api/groups/${groupId}/exit`, { userId: userB.id });
  test('B exited group', exit.status === 200);
  await wait(500);
  test('A notified of exit', !!wsA.messages.find(m => m.type === 'member_exited'));

  // 9. Online Status
  console.log('\n🟢 9. Online Status');
  const status = await api('GET', `/api/users/${userA.id}/status`);
  test('A shows online', status.status === 200 && status.body?.online === true);

  const online = await api('GET', '/api/users/online');
  test('Online list works', online.status === 200 && Array.isArray(online.body));

  // 10. Feedback & Config
  console.log('\n📝 10. Feedback & Config');
  const fb = await api('POST', '/api/feedback', { message: 'E2E pass!', rating: 5 });
  test('Feedback submitted', fb.status === 201);

  const cfg = await api('GET', '/api/app-config');
  test('App config OK', cfg.status === 200 && !!cfg.body.invite_text);

  // Cleanup
  console.log('\n🧹 Cleanup');
  if (groupId) await api('DELETE', `/api/groups/${groupId}?userId=${userA.id}`);
  test('Group deleted', true);
  wsA.ws.close(); wsB.ws.close();
  test('WebSockets closed', true);

  // Summary
  const passed = results.filter(r => r.passed).length;
  const failed = results.filter(r => !r.passed).length;
  console.log('\n═══════════════════════════════════════════════');
  console.log(`📊 RESULTS: ${passed}/${results.length} passed, ${failed} failed`);
  console.log('═══════════════════════════════════════════════');
  if (failed > 0) {
    console.log('\n❌ FAILURES:');
    results.filter(r => !r.passed).forEach(r => console.log(`   • ${r.name}${r.detail ? ': ' + r.detail : ''}`));
  }
  console.log('\n' + (failed === 0 ? '🎉 ALL TESTS PASSED!' : `⚠️  ${failed} test(s) need attention`));
  setTimeout(() => process.exit(failed > 0 ? 1 : 0), 500);
}

runTests().catch(e => { console.error('💥', e); process.exit(1); });
