// Dye House Weekly Dashboard — User Manual (Sinhala)
#let navy = rgb("#1e3a8a")
#let orange = rgb("#ea580c")
#let teal = rgb("#0f766e")

#set text(font: ("Noto Sans Sinhala", "Noto Sans"), size: 10.5pt, lang: "si")
#set par(justify: true, leading: 0.85em)
#set heading(numbering: "1.")

#show figure: set figure(supplement: none)
#show figure.where(kind: table): set figure(supplement: [ප්‍රස්තාරය])

#set page(
  paper: "a4",
  margin: (top: 2cm, bottom: 2.2cm, left: 1.9cm, right: 1.9cm),
  numbering: "1",
)

#show page: set page(
  footer: align(right,
    text(size: 7.5pt, fill: rgb("#64748b"))[Dye House Weekly Dashboard  ·  පිටුව ]
    + text(size: 7.5pt, fill: rgb("#64748b"))[counter(page).display()]
  )
)

// ---------- helper widgets ----------
#let info-box(title, body) = {
  box(width: 100%, inset: (x: 10pt, y: 8pt), radius: 7pt,
      fill: rgb("#eff6ff"), stroke: 0.8pt + rgb("#93c5fd"),
      block[
        #text(size: 9.5pt, weight: "bold", navy)[#title]
        #v(3pt)
        #text(size: 9.5pt)[#body]
      ])
}
#let warn-box(title, body) = {
  box(width: 100%, inset: (x: 10pt, y: 8pt), radius: 7pt,
      fill: rgb("#fffbeb"), stroke: 0.8pt + rgb("#fcd34d"),
      block[
        #text(size: 9.5pt, weight: "bold", rgb("#92400e"))[#title]
        #v(3pt)
        #text(size: 9.5pt)[#body]
      ])
}
#let ok-box(title, body) = {
  box(width: 100%, inset: (x: 10pt, y: 8pt), radius: 7pt,
      fill: rgb("#f0fdf4"), stroke: 0.8pt + rgb("#86efac"),
      block[
        #text(size: 9.5pt, weight: "bold", rgb("#166534"))[#title]
        #v(3pt)
        #text(size: 9.5pt)[#body]
      ])
}
#let ui(x) = text(weight: "bold")[#x]
#let step(n, t) = {
  v(4pt)
  grid(columns: (auto, 1fr), column-gutter: 8pt,
    box(width: 15pt, height: 15pt, radius: 50%, fill: navy,
        align(center)[#text(size: 8.5pt, weight: "bold", white)[#n]]),
    text(size: 10.5pt)[#t])
}

// ================= COVER =================
#v(3cm)
#align(center)[
  #image("logo.png", width: 140pt)
  #v(1.2cm)
  #text(size: 30pt, weight: "extrabold", navy, tracking: 0.02em)[DYE HOUSE]
  #text(size: 13pt, weight: "bold", rgb("#475569"), tracking: 0.28em)[WEEKLY PERFORMANCE DASHBOARD]
  #v(1.6cm)
  #box(width: 60%, fill: orange, inset: 3pt, radius: 3pt,
       align(center)[#text(size: 20pt, weight: "bold", white)[පරිශීලක මාර්ගෝපදේශය]])
  #v(0.9cm)
  #text(size: 11pt, rgb("#475569"))[සිංහල භාෂාවෙන් · App එක භාවිතා කරන විදිහ පියවරෙන් පියවර]
  #v(2.5cm)
  #text(size: 9.5pt, rgb("#64748b"))[සංස්කරණය 1.0  ·  2026 ඔක්තෝබර් 31  ·  Dye House Team]
  #v(0.3cm)
  #text(size: 9pt, rgb("#94a3b8"))[Better Colors · Better Tomorrow]
]
#pagebreak()

// ================= TOC =================
= මුලික ලැයිස්තුව
#outline(title: none, depth: 2)
#pagebreak()

// ================= 1. OVERVIEW =================
= App එක ගැන සරල පැහැදිලි කිරීම

මෙය #text(weight: "bold")[Dye House Weekly Performance Dashboard] යි — Dye House අංශයේ සතිපතා performance දත්ත ඒකේම එකතු කර, බැලිය හැකි විදිහට (charts, tables, % boxes) පෙන්වන web app එකකි.

#info-box("එක file එකකින් — internet නැතුව වැඩ කරයි", [
  App එක සම්පූර්ණයෙන්ම #text(weight: "bold")[එක HTML file එකක] (self-contained) තිබෙනවා. Browser එකක (Chrome / Edge උසාවි කළ යුතුයි) file එක open කරන විටම සියලුම features වැඩ කරයි — #text(weight: "bold")[internet connection එකක් අවශ්‍ය නැත].])

App එක track කරන දේ:

#table(
  columns: (auto, 1fr),
  table.header(
    [දත්තය],
    [විස්තරය],
  ),
  [Weekly PTP], [Production To Plan — planned / actual weight, PTP %, efficiency, Behind & Ahead tracking (8 batch boxes + issue categories)],
  [Weekly Downtime], [dye machines 21 ක downtime hours + Total Machine Capacity + Downtime %],
  [Batch / RK Utilization], [Excel වලින් WORKING MINUTES import → hours → capacity එකට %],
  [Weekly FTT], [First Time Through — REJECT / Rework / GOOD % + Reject FTT Summary (full pivot) + DYE HOUSE REJECT LIST auto export],
)

#pagebreak()

// ================= 2. HOME PAGE =================
= App එක open කරන විදිහ & Main page එක

#step(1, [App HTML file එක browser එකක open කරන්න (double-click හෝ "Open with" → Chrome/Edge).])
#step(2, [Page එක load වන විට main (home) page එක පෙනෙනවා — ඉහළ title, පිටුපසේ wallpaper, පහළට main cards 3.] )

== Header (ඉහළම තැන)
- වම්පැත්තේ #text(weight: "bold")[Logo + "Dye House"] title — මේක #text(weight: "bold")[click] කළොත් #text(weight: "bold")[ADD DATA] window එක open වෙනවා (data දැමුවාම).
- මැද/දකුණේ: #text(weight: "bold")[දිනය] (live), #text(weight: "bold")[Dye House Team], කාලගුණ තොරතුරු.
- ඉදිරියේම #text(weight: "bold")[Sun / Moon button] — #text(weight: "bold")[Light / Dark theme] එක toggle කරනවා (dashboard එක පාට එක වෙනස් වෙනවා).

== Main cards 3 — windows open කරන්න
Main page එකේ cards 3 ක් තියෙනවා. ඕනෑම එකක් #text(weight: "bold")[click] කළොත් අදාළ fullscreen window එක open වෙනවා:

#table(
  columns: (auto, 1fr),
  table.header([Card එක], [open වෙන window එක]),
  [#ui[Weekly PTP]], [Weekly PTP Update — PTP stats + Behind/Ahead charts + manual values + export],
  [#ui[Weekly Downtime]], [Weekly Downtime Update — machine 21 ක hours, total, capacity, Downtime %],
  [#ui[Weekly FTT]], [Weekly FTT Update — Reject/Rework/GOOD boxes + Reject FTT Summary + export tables],
)

#info-box("Windows close කරන විදිහ", [
  ඕනෑම fullscreen window එකක #text(weight: "bold")[ඉහළ දකුණු කෙළවරේ ✕ button] එක click කරන්න. `Esc` key වා භාවිතා කළ හැකියි.])

// ================= 3. ADD DATA =================
= ADD DATA — දත්ත ඇතුළත් කරන විදිහ

#step(1, [Main page එකේ ඉහළ වම්පැත්තේ #text(weight: "bold")[Logo එක click] කරන්න → ADD DATA window එක open වෙනවා.] )
#step(2, [ඉහළම තැන #text(weight: "bold")[Jump:] quick-nav buttons තියෙනවා — ඕනෑම section එකට 1 click වලින් jump කරන්න (Downtime, PTP Summary, Down Time, Weekly FTT, FTT Table Exports, FTT Details Exports).])

ADD DATA window එකේ ඇතුළත sections 6 ක් ඇතුළතම තියෙනවා. කිසියටම section එකක file input එකකට #text(weight: "bold")[Choose File] click කරලා Excel ගොනුව තෝරන්න — import ව්‍යාපාරය automatically වෙනවා.

// ---- 3.1 DOWNTIME
== 3.1  DOWNTIME (Excel import)

#table(
  columns: (auto, 1fr),
  table.header([විස්තරය], [අවශ්‍යයි]),
  [File format], [.xlsx / .xls / .csv],
  [Columns], [Date; Shift; Machine + machine codes 21 ක් (#ui[WDBK] … #ui[DCDD])],
  [Cell values], [දත්තය #text(weight: "bold")[minutes] වලින් (downtime minutes)],
)

#step(1, [#ui[DOWNTIME] card එකේ #text(weight: "bold")[Choose File] click කරලා Excel ගොනුව upload කරන්න.])
#step(2, [App එකේ file එකේ #text(weight: "bold")[code 21 ක් වල සතිපතා total] ගණනය කර, එය #text(weight: "bold")[60 න් බෙදලා] (minutes → #text(weight: "bold")[hours]) machine 21 ක boxes 21 පුරවනවා (1 decimal).])
#step(3, [Import result එක card එකේම green note එකක පෙන්නනවා (upload කළ row count එක සහිත).])

#warn-box("උක්ත columns නැතිවිනම්", [
  columns 21 න් ඕනෑවක් missing වුණොත්, app එක #text(weight: "bold")[warning] notification එකක් දෙනවා. Required columns 3 ක් (Date/Shift/Machine) missing වුණොත් #text(weight: "bold")[error].])

// ---- 3.2 PTP
== 3.2  PTP SUMMARY (Excel import හෝ Manual)

=== Excel import
- File format: #text(weight: "bold")[.xlsx / .xls / .csv] — sheet name #text(weight: "bold")[#ui[PTP SUMMARY]] විය යුතුයි.
- Required columns: #text(weight: "bold")[#ui[Date]], #text(weight: "bold")[#ui[BEHIND]], #text(weight: "bold")[#ui[AHEAD]], #text(weight: "bold")[#ui[PLANNED WEIGHT (Kg)]], #text(weight: "bold")[#ui[ACTUAL WEIGHT (Kg)]]
- Import වුණාම: #text(weight: "bold")[සියලුම imported days] Behind / Ahead / Weight charts එක පුරවනවා.
- Required column එකක් නැතිනම් → #text(weight: "bold")[error] (import වෙන්නේ නෑ). අනෙක් columns missing නම් → #text(weight: "bold")[warning + "IMPORT ANYWAY"] option.

=== Manual Values (හරි manual)
PTP Summary card එකේ #text(weight: "bold")[#ui[Manual Values]] subsection එකේ boxes 8 ක්:
#ui[Total Plan Batch] · #ui[Total Plan Slot] · #ui[Behind] · #ui[Ahead] · #ui[Plan Weight] · #ui[Actual Weight] · #ui[PTP] · #ui[Efficiency]

කිසියටම box එකක අකුරු ඇතුළත් කර change වුණාම — #text(weight: "bold")[PTP view එකට instantly apply] වෙනවා (2 decimals). Empty කරානම් box එක clear වෙනවා.

#ok-box("Excel vs Manual ප්‍රමුඛතාව", [
  PTP manual values #text(weight: "bold")[Excel import එකකින් පසු] upload කරානම්, Excel දත්තයි final වෙන්නේ. (Import එක manual values override කරනවා.])

// ---- 3.3 DOWN TIME
== 3.3  DOWN TIME (Manual hours)

- Machine 21 ක #text(weight: "bold")[hours] boxes manual වල ඇතුළත් කරන්න (DOWNTIME Excel import වලින් auto fill ද වෙනවා).
- #text(weight: "bold")[#ui[Total Down Time Hours]] = boxes 21 ක sum — #text(weight: "bold")[automatic] (ඔබ ඇතුළත් කරන්නේ නැතුව).
- #text(weight: "bold")[#ui[Total Machine Capacity]] — weekly machine capacity (hours) manual ඇතුළත් කරන්න.
- Utilization window එකේ: #text(weight: "bold")[Downtime %] = Down Time ÷ Capacity × 100 (1 decimal, automatic).

// ---- 3.4 BATCH / RK
== 3.4  BATCH & RK UTILIZATION (Excel only)

#table(
  columns: (auto, 1fr),
  table.header([විස්තරය], [අවශ්‍යයි]),
  [File format], [.xlsx / .xls #text(weight: "bold")[විතරයි] (CSV reject වෙනවා)],
  [Column], [#ui[WORKING MINUTES] — එහි #text(weight: "bold")[SUM] ගනී],
  [Auto calculation], [SUM ÷ 60 → #text(weight: "bold")[hours] (box එකට auto-fill) → #text(weight: "bold")[Utilization %] = hours ÷ Capacity × 100],
)

#step(1, [#ui[Batch Utilization] card එකේ #text(weight: "bold")[Choose File] click → Excel upload.])
#step(2, [App එකේ #ui[WORKING MINUTES] column එකේ SUM ÷ 60 ගණනය කර batch box එකට fill කරනවා.] )
#step(3, [Utilization card එකේ #text(weight: "bold")[%] capacity එකට සාපේක්ෂව automatic — Capacity value එක DOWN TIME section එකේ ඇතුළත් කරනවා.] )

// ---- 3.5 WEEKLY FTT
== 3.5  WEEKLY FTT (Excel import) — වැදගත්ම section

File format: #text(weight: "bold")[.xlsx / .xls විතරයි] (CSV reject). Columns 17 ක්:

#ui[Inspection Status] · #ui[Department] · #ui[Defect] · #ui[Dye Batch] · #ui[Component] · #ui[Grid] · #ui[PCs] · #ui[Garments] · #ui[%] · #ui[Dye Machine] · #ui[Customer] · #ui[Style] · #ui[Style Description] · #ui[Color] · #ui[Prd.Order] · #ui[Sales document] · #ui[Sales Document Item]

#step(1, [#ui[Weekly FTT] card එකේ #text(weight: "bold")[Choose File] click → FTT Excel upload කරන්න.] )
#step(2, [Import ව්‍යාපාරයේ #text(weight: "bold")[4 දෙනෙක්] automatic වෙනවා:] )

#ok-box("Import ව්‍යාපාරයේ සිදුවෙන දේ", [
  ① #text(weight: "bold")[#ui[REJECT FTT VALUE]] box එක → DYE HOUSE REJECT section එකේ #text(weight: "bold")["Sum of %" column එකේ total] (3 decimals) · ② #text(weight: "bold")[#ui[Rework FTT Value]] box එක → #text(weight: "bold")[#ui[KNITTING]] row එකේ #text(weight: "bold")[#ui[%]] · ③ #text(weight: "bold")[#ui[Reject FTT Summary]] table එක → Defect එකට group කළ #text(weight: "bold")[full PIVOT] (PCS desc + Total row) · ④ #text(weight: "bold")[#ui[DYE HOUSE REJECT LIST]] Excel file එක — #text(weight: "bold")[auto create + download] වෙනවා.])

#warn-box("Import fail වෙන අවස්ථාව", [
  File එකේ #text(weight: "bold")[#ui[REJECT]] row එකක #text(weight: "bold")[#ui[%]] value එකක් නැතිනම් → "No REJECT summary row with a % value found" error — file layout එක check කරන්න.])

// ---- 3.6 Manual Rework
== 3.6  Rework FTT Value — Manual Value box

#ui[Weekly FTT] card එකේ, upload area එක යටින් #text(weight: "bold")[#ui[Manual Value]] subsection එකක් තියෙනවා:

#step(1, [#ui[Rework FTT Value (%)] box එකක digit එකක් ඇතුළත් කරන්න (උදා: 5.36).])
#step(2, [Change ව්‍යාපාරයේ — FTT window එකේ #text(weight: "bold")[#ui[Rework FTT Value]] box එක #text(weight: "bold")[instantly] fill වෙනවා (2 decimals + #ui[%]).])
#step(3, ["Dashboard box now:" badge එකෙන් current value එක live පෙන්නනවා.] )

#info-box("උපදෙස්", [
  - Invalid number එකක් (අකුරු/negative) → red error, box එක unchanged.
  - Box එක empty කරන්න → value එක clear වෙනවා.
  - FTT Excel upload කරානම් #text(weight: "bold")[#ui[KNITTING]] row වලින් #text(weight: "bold")[override] — මේ manual box එකත් auto-sync වෙනවා.])

// ---- 3.7 TABLE EXPORTS
== 3.7  FTT TABLE EXPORTS (Excel වලින් tables පුරවන්න)

=== Weekly FTT — Table Exports (tables 3)
#ui[Weekly FTT Update] · #ui[Machine Wise Snagging] · #ui[Rework FTT Summary] · #ui[Style Wise FTT Summary]

=== Weekly FTT Details — Table Exports (tables 6)
#ui[Folding Mark] · #ui[Rework] · #ui[Dye Dot] · #ui[Burn Mark] · #ui[Snagging] · #ui[Less Component]

#step(1, [ඕනෑම table එකකට ව්‍යාපාරයේ Excel ගොනුවක් (.xlsx / .xls) upload කරන්න.] )
#step(2, [App එකේ file එකේ #text(weight: "bold")[header row] auto-detect කර (නැතහොත් position-based), FTT window එකේ අදාළ table එක පුරවනවා.] )
#step(3, [Table එකේ #text(weight: "bold")[Export] button වලින් Excel download කරන්න පුළුවන්.] )

#pagebreak()

// ================= 4. WINDOWS =================
= Fullscreen Windows — එක එක තිබෙන දේ

#table(
  columns: (1.2fr, 2.2fr),
  table.header([Window එක], [ඇතුළත තියෙන දේ]),
  [Weekly PTP Update], [PTP stat boxes (Plan Batch/Slot, Behind, Ahead, Weights, PTP %, Efficiency) + Behind/Ahead charts (all days) + manual values + Excel export],
  [Behind Summary], [batch boxes 8 + issue categories (System / Planning / Internal / Knitting) + Lastest Behind + Behind table (date data other sheets වලින්)],
  [Weekly Downtime Update], [machine 21 hours boxes + Total Down Time + Capacity + Downtime % + export],
  [Batch / RK Utilization], [batch & RK hours boxes + Utilization % cards (vs capacity) + Downtime %],
  [Weekly FTT Update], [Reject / Rework / GOOD % boxes + #text(weight: "bold")[Reject FTT Summary] (full pivot table) + Table Exports 3 + Excel export],
  [FTT Details], [FTT details tables 6 (Folding Mark, Rework, Dye Dot, Burn Mark, Snagging, Less Component) + export],
)

#info-box("උපදෙස්", [
  Window 6 කම #text(weight: "bold")[Aero-glass] (Windows Vista style) transparency වලින් — පිටුපසේ wallpaper එක blur වෙලා පෙනෙනවා. Light mode එකේද window එක light glass.])

// ================= 5. EXPORTS =================
= Export වෙන files

== DYE HOUSE REJECT LIST (auto)
Weekly FTT Excel upload ව්‍යාපාරයේ, app එක #text(weight: "bold")[නව Excel file එකක්] auto-create කර #text(weight: "bold")[auto-download] කරනවා:

- File name: `#text(size: 9pt)[{upload file name} (DYE HOUSE REJECT LIST).xlsx]`
- Content: #text(weight: "bold")[header + DYE HOUSE section row එක (#ui[REJECT] ලෙස relabel) + එහි detail rows විතරයි] — අනෙක් rows නැත.
- File එකේ #text(weight: "bold")[#ui[PIVOT]] sheet එකක්ද තියෙනවා (Defect-wise pivot: PCS, Garments, % + Total row).

== Window exports
ඕනෑම window එකක #text(weight: "bold")[Export] button වලින් — window එකේ current data (tables + stats) Excel ලෙස download වෙනවා.

// ================= 6. RULES =================
= වැදගත් රීති & සාමාන්‍ය ගැටලු

== File formats — summary
#table(
  columns: (auto, auto, 1fr),
  table.header([Section], [Formats], [අමතරයි]),
  [DOWNTIME], [.xlsx .xls .csv], [minutes ÷ 60 → hours (auto)],
  [PTP SUMMARY], [.xlsx .xls .csv], [sheet "PTP SUMMARY" + required columns 5],
  [BATCH / RK], [.xlsx .xls], [WORKING MINUTES SUM ÷ 60 (auto)],
  [WEEKLY FTT], [.xlsx .xls], [columns 17 + REJECT/KNITTING rows],
  [FTT Table Exports], [.xlsx .xls], [header auto-detect],
)

#warn-box("CSV reject වෙන තැන්", [
  #text(weight: "bold")[Batch / RK] සහ #text(weight: "bold")[Weekly FTT] sections වල #text(weight: "bold")[.csv upload කළොත් reject] — ".xlsx / .xls only" notification. ඒවා Excel ලෙස save කරලා නැවත upload කරන්න.])

== Import override rules
- #text(weight: "bold")[Excel import] වැදගත්ම — manual values වලින් පසු import කරානම්, import වැදගත්ම.
- Manual values Excel import වලින් පසු ඇතුළත් කළොත්, manual වැදගත්ම (පරිශීලකා intent එක).
- Rework manual box එක — FTT import වලින් KNITTING row override කරනවා (box එක auto-sync).

== පුරුදු ගැටලු
#table(
  columns: (1.3fr, 2.1fr),
  table.header([ගැටලුව], [ව්‍යාපාරය]),
  [Window එක empty / හිස් බවක් පෙනේවිනම්], [Browser cache එක — #text(size: 9pt, weight: "bold")[Ctrl+Shift+R] (hard refresh) කරන්න. File එක close කරලා නැවත open කළ යුතුයි.] ,
  [Import "No REJECT summary row" error], [FTT file එකේ REJECT row එකේ % value එකක් නැත — Excel layout එක check කරන්න.] ,
  [PTP import warning], [Required column එකක් missing — warning වලින් "IMPORT ANYWAY" option එක තියෙනවා.] ,
  [Charts නැත], [පළමු data import (Excel/manual) කරානම් charts auto-render වෙනවා.] ,
)

// ================= 7. GLOSSARY =================
= ශබ්දකෝෂය (Glossary)

#table(
  columns: (auto, 1fr),
  table.header([තේරුම], [අර්ථය]),
  [FTT], [First Time Through — පළමු වරටම හරි (defect-free) production %],
  [PTP], [Production To Plan — plan එකට සාපේක්ෂව actual production %],
  [Reject FTT Value], [REJECT data වල Sum of % column එකේ total — weekly reject level],
  [Rework FTT Value], [KNITTING row වල % — rework වෙන garments percentage],
  [GOOD], [GOOD row වල % — defect-free percentage],
  [Capacity], [Weekly machine operating capacity (hours)],
  [Downtime %], [Total Down Time ÷ Capacity × 100],
  [Batch / RK Utilization], [WORKING MINUTES ÷ 60 → hours → ÷ Capacity × 100],
  [Behind / Ahead], [Schedule එකට සාපේක්ෂව delay / lead (days/units)],
  [DYE HOUSE REJECT LIST], [REJECT block විතරම — section row එක REJECT ලෙස relabel වුණු Excel export],
)

#v(1.5cm)
#box(width: 100%, fill: rgb("#f8fafc"), stroke: rgb("#e2e8f0"), inset: 12pt, radius: 8pt,
  align(center)[
    #text(size: 9.5pt, weight: "bold", rgb("#334155"))[ප්‍රශ්න / යෝජනා තිබේවිනම් — Dye House Team එකට සම්බන්ධ වන්න.]
    #v(2pt)
    #text(size: 8.5pt, rgb("#64748b"))[Better Colors · Better Tomorrow]
  ])
