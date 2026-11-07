// ADD DATA quick-nav + FTT flow regression (jsdom)
// run: node /home/user/dashboard_tests/addata_nav_test.js
const fs = require('fs');
const { JSDOM } = require('/tmp/adt/node_modules/jsdom');
const html = fs.readFileSync('/home/user/dashboard/index.html', 'utf-8');
let pass = 0, fail = 0;
const ok = (c, l) => { if (c) { pass++; console.log('  PASS:', l); } else { fail++; console.log('  FAIL:', l); } };
function boot() {
  const dom = new JSDOM(html, { runScripts: 'dangerously', url: 'http://localhost/', pretendToBeVisual: true });
  dom.window.addEventListener('error', e => console.log('  WINERR:', e.message));
  return dom;
}
const txt = (dom, id) => { const el = dom.window.document.getElementById(id); return el ? el.textContent : '(missing)'; };
function openAddData(dom) { dom.window.openAddDataView(); return new Promise(r => setTimeout(r, 400)); }
const FU_HEAD = ['Inspection Status','Department','Defect','Dye Batch','Component','Grid','PCs','Garments','%','Dye Machine','Customer','Style','Style Description','Color','Prd.Order','Sales document','Sales Document Item'];
function sec(dept, pcs, g, p) { const c = new Array(17).fill(''); c[1]=dept; c[6]=pcs; c[7]=g; c[8]=p; return c; }
function det(defect, pcs, gar, pct) { const c = new Array(17).fill(''); c[2]=defect; c[3]='13261211'; c[5]=6; c[6]=pcs; c[7]=gar; c[8]=pct; c[9]='EM19E4'; c[10]='LULULEMON'; return c; }
function statusRow(s, pcs, g, p) { const c = new Array(17).fill(''); c[0]=s; c[6]=pcs; c[7]=g; c[8]=p; return c; }
function mockXlsx(dom, grid) {
  const wb = { SheetNames: ['FTT'], Sheets: { FTT: {} } };
  dom.window.XLSX = {
    read: () => wb,
    utils: { sheet_to_json: (ws) => (wb.Sheets.FTT === ws ? grid : null), aoa_to_sheet: () => ({}), book_new: () => ({}), book_append_sheet: () => {} },
    write: () => new ArrayBuffer(8)
  };
}
function mockSheets(dom, sheets) {
  const wb = { SheetNames: Object.keys(sheets), Sheets: {} };
  wb.SheetNames.forEach(n => { wb.Sheets[n] = {}; });
  dom.window.XLSX = {
    read: () => wb,
    utils: { sheet_to_json: (ws) => { for (const n of wb.SheetNames) { if (wb.Sheets[n] === ws) return sheets[n]; } return null; }, aoa_to_sheet: (g) => ({}), book_new: () => ({}), book_append_sheet: () => {} },
    write: () => new ArrayBuffer(8)
  };
}
function uploadTo(dom, id, name) {
  const file = new dom.window.File(['fake'], name);
  const input = dom.window.document.getElementById(id);
  Object.defineProperty(input, 'files', { value: [file], configurable: true });
  input.dispatchEvent(new dom.window.Event('change', { bubbles: true }));
  return new Promise(r => setTimeout(r, 500));
}
function uploadFu(dom, name) {
  const file = new dom.window.File(['fake'], name);
  const input = dom.window.document.getElementById('adFuFile');
  Object.defineProperty(input, 'files', { value: [file], configurable: true });
  input.dispatchEvent(new dom.window.Event('change', { bubbles: true }));
  return new Promise(r => setTimeout(r, 500));
}
(async () => {
  console.log('T103: sticky quick-nav present with all 5 section targets');
  {
    const dom = boot();
    await openAddData(dom);
    const doc = dom.window.document;
    const nav = doc.querySelector('#addDataFullscreen .ad-scroll > .sticky');
    ok(!!nav, 'sticky nav exists at top of scroll container');
    const btns = nav ? Array.from(nav.querySelectorAll('button.ad-navbtn')) : [];
    ok(btns.length === 5, '5 nav buttons');
    const ids = ['adSecDt', 'adPpCard', 'adSecDownTime', 'adSecMachineUtil', 'adSecFtt'];
    let all = true;
    ids.forEach(id => { if (!doc.getElementById(id)) all = false; });
    ok(all, 'all 5 anchor targets exist');
    // nav sits before the DOWNTIME panel
    const scroll = doc.querySelector('#addDataFullscreen .ad-scroll');
    ok(scroll.children[0] === nav, 'nav is first child (above DOWNTIME)');
    dom.window.close();
  }
  console.log('T104: nav buttons call adScrollTo without error');
  {
    const dom = boot();
    await openAddData(dom);
    const doc = dom.window.document;
    if (typeof dom.window.Element.prototype.scrollIntoView !== 'function') {
      dom.window.Element.prototype.scrollIntoView = function () {}; // jsdom has no layout; real browsers do
    }
    let clicked = 0, err = null;
    dom.window.addEventListener('error', e => { err = e.message; });
    doc.querySelectorAll('#addDataFullscreen .ad-scroll > .sticky button.ad-navbtn').forEach(b => {
      b.click(); clicked++;
    });
    ok(clicked === 5, 'clicked 5 buttons');
    ok(!err, 'no page errors (' + (err || 'none') + ')');
    dom.window.close();
  }
  console.log('T109: DOWNTIME import (minutes → hours in boxes)');
  {
    const dom = boot();
    await openAddData(dom);
    const CODES = ['WDBK','WDBD','WDBP','MBDE','PSWE','RPSD','RPSK','NDRD','RIND','CSND','SNPE','TRMD','TRMH','PLCL','MSVP','ADDD','OPCP','MCWD','MCWP','SMDD','DCDD'];
    const head = ['Date','Shift','Machine'].concat(CODES);
    const r1 = new Array(24).fill(''); r1[0]='27/10/2026'; r1[1]='A'; r1[2]='All'; r1[3]=120;
    const r2 = new Array(24).fill(''); r2[0]='28/10/2026'; r2[1]='B'; r2[2]='All'; r2[3]=30; r2[4]=60;
    mockSheets(dom, { 'DOWNTIME': [head, r1, r2] });
    await uploadTo(dom, 'adDtFile', 'dt.xlsx');
    const v0 = parseFloat(dom.window.document.getElementById('adDtV0').value);
    const v1 = parseFloat(dom.window.document.getElementById('adDtV1').value);
    ok(Math.abs(v0 - 2.5) < 1e-9, 'WDBK box = (120+30)/60 = 2.5 h');
    ok(Math.abs(v1 - 1) < 1e-9, 'WDBD box = 60/60 = 1 h');
    dom.window.close();
  }
  console.log('T110: PTP import (charts + dataset)');
  {
    const dom = boot();
    await openAddData(dom);
    const head = new Array(25).fill('');
    head[0]='Date'; head[1]='BEHIND'; head[2]='AHEAD'; head[23]='PLANNED WEIGHT (Kg)'; head[24]='ACTUAL WEIGHT (Kg)';
    const d1 = new Array(25).fill(''); d1[0]='27/10/2026'; d1[1]=10; d1[2]=5; d1[23]=100; d1[24]=110;
    const d2 = new Array(25).fill(''); d2[0]='28/10/2026'; d2[1]=20; d2[2]=15; d2[23]=200; d2[24]=210;
    mockSheets(dom, { 'PTP SUMMARY': [head, d1, d2] });
    await uploadTo(dom, 'adPpFile', 'ptp.xlsx');
    ok(txt(dom, 'adPpImportResult').includes('PTP Summary imported'), 'result panel confirms import');
    ok(dom.window.eval('adPpDataset && adPpDataset.rows.length') === 2, 'dataset has 2 days');
    const svg = dom.window.document.querySelector('#ptpChartBehind svg');
    ok(!!svg, 'Behind chart rendered');
    ok(!!dom.window.document.querySelector('#ptpChartAhead svg'), 'Ahead chart rendered');
    dom.window.close();
  }
  console.log('T111: PTP import fills Behind Summary boxes from LAST dated row');
  {
    const dom = boot();
    await openAddData(dom);
    const H = ['DATE','PLAN BATCH','PLAN SLOT','NDI','LDI','WEIGH T ISSUE','ERROR','S/OUT','TO DYE','TO SCAN','HOLD','MFI','DYEING','NO RECIPE','PLANNING ISSUE','BEHIND','BEHIND QTY','AHEAD','Ahead qty','DAILY PTP','DAILY PTP (INTERNAL)','DAILY TRACKER WEIGHT ( Kg)','PLANNED WEIGHT (Kg)','ACTUAL WEIGHT (Kg)','EFF'];
    // real Excel DATE cells (cellDates:true) arrive as window-realm Date objects (displayed as '01-ඔක්ත' in the cell)
    const D = (d) => new dom.window.Date(2026, 9, d);
    const r1 = [D(1),55,40,15,0,1,1,2,30,3,42,0,12,0,0,106,26458,192,60968,'65%','70%','',3135,2738,'85%'];
    const r2 = [D(2),103,49,13,0,1,2,7,34,3,36,0,8,0,2,104,27720,170,55248,'75%','86%','',3508,2316,'88%'];
    const r3 = [D(3),61,46];
    const r4 = [D(4),67,38,9,2,3,4,5,60,2,20,1,7,2,1,90,20000,150,50000,'70%','80%','',3007,2500,'83%'];
    const r5 = new Array(25).fill(999); r5[0] = ''; // no date -> must be ignored
    mockSheets(dom, { 'PTP SUMMARY': [H, r1, r2, r3, r4, r5] });
    await uploadTo(dom, 'adPpFile', 'ptp.xlsx');
    ok(txt(dom, 'adPpImportResult').includes('PTP Summary imported'), 'PTP import ok');
    ok(txt(dom, 'adPpImportResult').includes('Oct 04'), 'result names last dated row (Oct 04)');
    const expect = { adBhCard0:'60', adBhCard1:'9', adBhCard2:'20', adBhCard3:'3', adBhCard4:'5', adBhCard5:'2', adBhCard6:'7', adBhNoRecipe:'2', adBhError:'4', adBhCard7:'1' };
    Object.keys(expect).forEach(id => ok(txt(dom, id) === expect[id], id + ' = ' + expect[id] + ' (from last dated row)'));
    // category cards: Internal + External only, centered; Planning/System boxes removed
    ok(!dom.window.document.getElementById('adBhCat2'), 'Planning Issue box removed');
    ok(!dom.window.document.getElementById('adBhCat3'), 'System Issue box removed');
    const catGrid = dom.window.document.getElementById('adBhCat0').parentElement.parentElement;
    ok(catGrid.children.length === 2, 'exactly 2 category cards remain');
    ok(catGrid.className.includes('mx-auto'), 'category cards centered');
    const bhWin = dom.window.document.getElementById('behindUpdateFullscreen');
    ok(bhWin.textContent.includes('External Issue'), 'knitting box renamed to External Issue');
    // v65: a standalone "Planning Issue" status box was added to the left column (fed by the PTP SUMMARY sheet)
    ok(!bhWin.textContent.includes('System Issue'), 'System Issue label gone');
    ok(!!dom.window.document.getElementById('adBhPlanning'), 'Planning Issue status box present');
    ok(bhWin.textContent.includes('Planning Issue'), 'Planning Issue label shown');
    ok(dom.window.document.getElementById('adBhPlanning').parentElement.className.includes('col-span-2'), 'Planning Issue box spans the bottom row');
    // category totals + Latest Behind recompute from the filled boxes
    ok(txt(dom, 'adBhCat0') === '93', 'Internal total = 93 (60+20+5+7+1)');
    ok(txt(dom, 'adBhCat1') === '14', 'External total = 14 (9+3+2)');
    // v71: Latest Behind prefers the PTP SUMMARY "BEHIND" last value; falls back to Internal+External
    const prevLatest = dom.window.adPtpLatestBehind;
    dom.window.adPtpLatestBehind = null;
    dom.window.adUpdateBehindLatestTotal();
    ok(txt(dom, 'behindLatestVal') === '107', 'Latest Behind = 107 (93+14) when no PTP value is loaded');
    dom.window.adPtpLatestBehind = 137;
    dom.window.adUpdateBehindLatestTotal();
    ok(txt(dom, 'behindLatestVal') === '137', 'Latest Behind = 137 from the PTP BEHIND column');
    dom.window.adPtpLatestBehind = 96.456;
    dom.window.adUpdateBehindLatestTotal();
    ok(txt(dom, 'behindLatestVal') === '96.46', 'Latest Behind rounds to 2 decimals (96.46)');
    dom.window.adPtpLatestBehind = null;
    dom.window.adUpdateBehindLatestTotal();
    ok(txt(dom, 'behindLatestVal') === '107', 'Latest Behind falls back to 107 when the PTP value is cleared');
    dom.window.adPtpLatestBehind = (prevLatest === undefined ? null : prevLatest);
    // all rendered chart lines must be straight (no bezier C segments)
    let hasL = false, hasC = false, nPaths = 0;
    dom.window.document.querySelectorAll('#ptpChartBehind path, #ptpChartWeight path').forEach(pth => {
      const d = pth.getAttribute('d') || '';
      if (!d) return;
      nPaths++;
      if (/\sC\s/.test(d)) hasC = true;
      if (/\sL\s/.test(d)) hasL = true;
    });
    ok(nPaths > 0 && hasL, 'chart paths use straight L segments');
    ok(!hasC, 'chart paths contain no curve (C) segments');
    // Behind Summary chart: smaller fixed-height band, non-compact badges for <= 7 days
    const bhC = dom.window.document.getElementById('behindChart');
    ok(bhC.className.includes('h-36'), 'Behind Summary chart band is the smaller h-36');
    const bhCard = bhC.parentElement.parentElement;
    ok(bhCard.className.includes('col-span-8') && bhCard.className.includes('self-center'), 'chart square vertically centered in its column');
    const boxCol = dom.window.document.getElementById('adBhCard0').parentElement.parentElement;
    ok(boxCol.className.includes('grid-cols-2') && boxCol.className.includes('col-span-4'), 'value boxes back in the original 2-column layout (col-span-4)');
    const bhRects = dom.window.document.querySelectorAll('#behindChart svg rect');
    const bhTexts = dom.window.document.querySelectorAll('#behindChart svg text');
    const allBig = bhRects.length > 0 && Array.from(bhRects).every(r => r.getAttribute('width') === '34');
    const bigFont = Array.from(bhTexts).some(t => t.getAttribute('font-size') === '11');
    ok(allBig && bigFont, '7-day-or-fewer values render non-compact (34px badges, 11px font)');
    dom.window.close();
  }
  console.log('T112: PTP import fills Weekly PTP Update window boxes (last values + sums)');
  {
    const dom = boot();
    await openAddData(dom);
    const H = ['DATE','PLAN BATCH','PLAN SLOT','NDI','LDI','WEIGH T ISSUE','ERROR','S/OUT','TO DYE','TO SCAN','HOLD','MFI','DYEING','NO RECIPE','PLANNING ISSUE','BEHIND','BEHIND QTY','AHEAD','Ahead qty','DAILY PTP','DAILY PTP (INTERNAL)','DAILY TRACKER WEIGHT ( Kg)','PLANNED WEIGHT (Kg)','ACTUAL WEIGHT (Kg)','EFF'];
    const D = (d) => new dom.window.Date(2026, 9, d);
    const r1 = [D(1),55,40,15,0,1,1,2,30,3,42,0,12,0,0,106,26458,192,60968,'65%','70%','',3135,2738,'85%'];
    const r2 = [D(2),103,49,13,0,1,2,7,34,3,36,0,8,0,2,104,27720,170,55248,'75%','86%','',3508,2316,'88%'];
    const r3 = [D(3),61,46];
    const r4 = [D(4),67,38];
    const r5 = [D(5)]; // date only, no values (empty rows of the sheet)
    const r6 = [D(6)];
    mockSheets(dom, { 'PTP SUMMARY': [H, r1, r2, r3, r4, r5, r6] });
    await uploadTo(dom, 'adPpFile', 'ptp.xlsx');
    ok(txt(dom, 'adPpImportResult').includes('PTP Summary imported'), 'PTP import ok');
    ok(txt(dom, 'behindStatVal') === '104', 'Behind box = last BEHIND value (104)');
    ok(txt(dom, 'aheadVal') === '170', 'Ahead box = last AHEAD value (170)');
    ok(txt(dom, 'ptpPlanBatchVal') === '286', 'Total Plan Batch = SUM (55+103+61+67=286)');
    ok(txt(dom, 'ptpPlanSlotVal') === '173', 'Total Plan Slot = SUM (40+49+46+38=173)');
    ok(txt(dom, 'ptpVal') === '75%', 'PTP box = last DAILY PTP value (75%)');
    ok(txt(dom, 'efficiencyVal') === '88%', 'Efficiency box = last EFF value (88%)');
    await new Promise(r => setTimeout(r, 60));
    ok(txt(dom, 'ptpCardVal') === '75%', 'main Weekly PTP card shows the imported PTP value (75%)');
    ok(txt(dom, 'effCardVal') === '88%', 'main Efficiency card shows the imported EFF value (88%)');
    dom.window.close();
  }
  console.log('T113: main window Weekly PTP card mirrors the PTP update window value');
  {
    const dom = boot();
    await new Promise(r => setTimeout(r, 200));
    ok(!!dom.window.document.getElementById('ptpCardVal'), 'main card has a PTP value element');
    ok(txt(dom, 'ptpCardVal') === '66%', 'card shows the PTP window value on load (66%)');
    dom.window.document.getElementById('ptpVal').textContent = '72%';
    dom.window.eval('adSyncPtpCard()');
    ok(txt(dom, 'ptpCardVal') === '72%', 'card updates when the PTP window value changes (72%)');
    // Efficiency: PTP update window value mirrored to the main Efficiency card
    ok(!!dom.window.document.getElementById('effCardVal'), 'main Efficiency card has a value element');
    ok(txt(dom, 'effCardVal') === '87%', 'Efficiency card shows the window value on load (87%)');
    dom.window.document.getElementById('efficiencyVal').textContent = '91%';
    dom.window.eval('adSyncPtpCard()');
    ok(txt(dom, 'effCardVal') === '91%', 'Efficiency card updates when the window value changes (91%)');
    dom.window.close();
  }
  console.log('T114: Machine Utilization area (RK + Batch together, no Excel uploads)');
  {
    const dom = boot();
    await openAddData(dom);
    const d = dom.window.document;
    ok(!d.getElementById('adDtRkFile'), 'RK Utilization Excel upload removed');
    ok(!d.getElementById('adBtFile'), 'Batch Utilization Excel upload removed');
    const sec = d.getElementById('adSecMachineUtil');
    ok(!!sec, 'Machine Utilization area exists');
    ok(!!sec && !!sec.querySelector('#adDtRkVal'), 'RK Utilization input sits inside Machine Utilization');
    ok(!!sec && !!sec.querySelector('#adBtVal'), 'Batch Utilization input sits inside Machine Utilization');
    ok(sec.textContent.includes('Machine Utilization'), 'area is labelled Machine Utilization');
    dom.window.close();
  }
  console.log('T115: main Weekly PTP card updates automatically (no manual sync call)');
  {
    const dom = boot();
    await new Promise(r => setTimeout(r, 250));
    const d = dom.window.document;
    ok(txt(dom, 'ptpCardVal') === '66%', 'card shows the PTP window value on load (66%)');
    d.getElementById('ptpVal').textContent = ' 74% ';
    await new Promise(r => setTimeout(r, 120));
    ok(txt(dom, 'ptpCardVal') === '74%', 'card follows the PTP window value automatically (74%)');
    d.getElementById('efficiencyVal').textContent = '93%';
    await new Promise(r => setTimeout(r, 120));
    ok(txt(dom, 'effCardVal') === '93%', 'Efficiency card follows the window value automatically (93%)');
    dom.window.close();
  }
  console.log('T116: Machine Utilization — one Excel, EH85H9/FP85H10 rows dropped, RK… rows -> RK');
  {
    const dom = boot();
    await openAddData(dom);
    const H = ['Actual Dye Module','Actual Machine','Plan Machine','Machine Size','Ready Date','Dye Batch Number','Fabric content','Customer Color Description','Internal Color Code','Batch Weight','Garments per Batch','Total Pieces','Efficiency','Customer','Customer Style Description','Customer Color Code','Entry Date','Additions','Standard Minutes','Working Minutes'];
    const row = (mach, batchNo, wm) => { const r = new Array(20).fill(''); r[1] = mach; r[5] = batchNo; r[18] = 999; r[19] = wm; return r; };
    mockSheets(dom, { 'Machine Util': [H,
      row('EH85H9', 'RK12345', 600),   // dropped
      row('FP85H10', 'NORMAL1', 300),  // dropped
      row('EM5H3', 'RK99', 600),       // RK
      row('EM4H4', 'RK100', 300),      // RK
      row('EM1A1', 'rk777', 60),       // RK (lower-case)
      row('EM7E5', '13266686', 1200),  // Batch
      row('EM10C4', '13266687', 600)   // Batch
    ] });
    await uploadTo(dom, 'adMuFile', 'machine.xlsx');
    const res = txt(dom, 'adMuResult');
    ok(res.includes('Machine Utilization imported'), 'single-file import ok');
    ok(res.includes('2 row(s) removed'), 'rows of EH85H9 / FP85H10 are removed (2 rows)');
    // RK = (600 + 300 + 60) / 60 = 16 h   ·  Batch = (1200 + 600) / 60 = 30 h
    ok(dom.window.document.getElementById('adDtRkVal').value === '16', 'RK Utilization = RK… rows 960 min / 60 = 16');
    ok(dom.window.document.getElementById('adBtVal').value === '30', 'Batch Utilization = other rows 1800 min / 60 = 30');
    ok(txt(dom, 'adMuResult').includes('16 h') && txt(dom, 'adMuResult').includes('30 h'), 'result panel reports both hours');
    ok(dom.window.document.getElementById('adMuFile') !== null, 'one upload input exists in the Machine Utilization area');
    dom.window.close();
  }
  console.log('T117: Machine Utilization rejects a file without the required headers');
  {
    const dom = boot();
    await openAddData(dom);
    mockSheets(dom, { 'Bad': [['Only', 'Two'], ['a', 'b']] });
    await uploadTo(dom, 'adMuFile', 'bad.xlsx');
    ok(txt(dom, 'adMuResult').includes('Required column headers are missing'), 'missing headers are reported');
    ok(dom.window.document.getElementById('adBtVal').value === '', 'Batch input left untouched');
    dom.window.close();
  }
  console.log('\n' + pass + ' PASS / ' + fail + ' FAIL');
  process.exit(fail ? 1 : 0);
})();
