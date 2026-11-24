# AI agent yo‘riqnomasi: tokenni tejash, Project Memory va Code Intelligence

**Versiya:** 2026-11-22  
**Auditoriya:** Jcode, Google Antigravity, Gemini CLI va MCP ishlata oladigan boshqa kod yozuvchi agentlar  
**Maqsad:** Agent token sarfini kamaytirib, kamroq takroriy kontekst bilan loyihani tushunsin va kod ustida samaraliroq ishlasin. Buning uchun loyiha xotirasi oldingi qaror va xatolarni qayta tushuntirishni, kod grafigi esa kerakli bog‘liqlikni topish uchun ko‘p faylni o‘qib chiqishni kamaytirishga yordam beradi. Token tejalishi kafolatlanmaydi: MCP chaqiruvlarining o‘zi ham token va vaqt sarflashi mumkin, shuning uchun agent faqat vazifaga aloqador vositani maqsadli ishlatsin.

> Bu faylda tokenlar, parollar yoki maxfiy ma’lumotlar bo‘lmasin. Agent ushbu faylni loyiha kontekstida ko‘rsa, quyidagi ish qoidalariga amal qilsin.

## Mandatory agent contract

When this guide is available in the project context, follow it before editing code:

1. Confirm the exact project root. Never index the user's home folder or the whole disk by default.
2. If `projectmem` is available, read its instructions and project summary, then precheck files before editing.
3. If `codebase-memory-mcp` is available, check index status and use its graph for relevant structural questions. Do not claim a graph is current unless verified.
4. After a real command, build, or test failure, record the attempted approach, evidence, and verified reason with `projectmem`. Do not save guesses as facts.
5. After a verified fix, record the root cause, fix, and test result. Put important team lessons in a reviewed, shared project document.
6. Do not expose secrets or commit/push changes without user authorization.
7. To save tokens, call only the MCP tool relevant to the task, make focused queries, and avoid unnecessary large outputs or full re-indexes after every edit.

## Agent uchun qisqa topshiriq

Sen kod yozuvchi agentsan. Kodga o‘zgartirish kiritishdan avval loyiha ildizini aniqlagin, mavjud loyiha xotirasini va tegishli kod tuzilmasini tekshirgin. Kodni o‘zing tahrir qilasan. `codebase-memory-mcp` kodni tahrir qilmaydi, u kodning tuzilishi va bog‘liqliklari grafigini yaratadi hamda yangilaydi. `projectmem` esa qarorlar, xatolar, sinab ko‘rilgan yo‘llar va yechimlar haqidagi tajribani saqlaydi.

MCP server mavjudligini tekshirmasdan, uning ishlayotganini yoki indeks yangilanganini da’vo qilma. Asbob mavjud bo‘lmasa, buni aniq ayt.

## Tokenni tejash: asosiy maqsad

Bu ikki MCP vositasini qo‘shishdan asosiy ko‘zlangan foyda — agent bir xil loyiha kontekstini qayta-qayta o‘qib yoki foydalanuvchidan qayta so‘rab token sarflamasligi, kerakli kodni esa butun repozitoriy bo‘ylab keraksiz qidiruvsiz topishidir.

- `projectmem` oldingi qarorlar, tasdiqlangan xatolar va yechimlarni eslab qolishga yordam beradi. Shu tariqa agentga bir xil tarixni har sessiyada boshidan tushuntirish shart bo‘lmaydi.
- `codebase-memory-mcp` modul, fayl, symbol va dependency aloqalarini maqsadli qidirishga yordam beradi. Agent ko‘p faylni to‘liq chiqarish o‘rniga tegishli bog‘liqlikni so‘rashi mumkin.
- Ikkalasini ham har bir vazifada chaqirish shart emas. Oddiy, mustaqil kichik o‘zgarishda MCP chaqiruvi ortiqcha bo‘lishi mumkin. Vazifaga mosini tanla, aniq savol ber va natijadan faqat kerakli qismini ishlat.
- Token tejalishi kafolat emas: tool chaqiruvi va uning javobi ham kontekst egallaydi. Katta summary, butun grafik yoki ortiqcha indekslashni so‘rash token sarfini oshirishi mumkin.

### `projectmem`: tajriba va loyiha xotirasi

Quyidagilarni saqlash uchun ishlatiladi:

- muhim arxitektura qarorlari va ularning sababi;
- tasdiqlangan xatolar, muvaffaqiyatsiz urinishlar va ishlamagan yondashuvlar;
- tuzatishlar va tekshiruv natijalari;
- loyihaga xos gotcha, talab va cheklovlar.

Maqsad agentga “bu yo‘lni avval sinab ko‘rganmiz va mana shu dalil sabab ishlamagan” deb eslatish. Bu takroriy xatolarni va qayta-qayta kontekst tushuntirishni kamaytirib, token tejashga yordam beradi, lekin token tejalishini kafolatlamaydi.

### `codebase-memory-mcp`: kod tuzilmasi grafigi

Koddagi modul, fayl, symbol, import va dependency bog‘liqliklarini izlash uchun ishlatiladi. Masalan, “bu API route qayerdan chaqiriladi?” yoki “bu modelga qaysi fayllar bog‘langan?” degan savollarga yordam beradi.

Kodni keng ko‘lamda ko‘chirib chiqarish o‘rniga, agent kerakli modul/fayl/symbol va dependency aloqasini maqsadli izlab topishi mumkin. Bu keraksiz kontekstni kamaytirib token tejashga yordam beradi. U kodni o‘zgartirmaydi va nima uchun biror yondashuv xato bo‘lganini o‘zi tushuntirmaydi. Buning uchun `projectmem` xotirasi kerak.

### Agentning vazifasi

Agent foydalanuvchi ko‘rsatgan loyiha fayllarini tahrir qiladi, testlarni bajaradi, natijani tekshiradi va kerak bo‘lsa ikkala MCP vositasini chaqiradi. Kod o‘zgartirish, grafikni yangilash va tajribani yozish alohida amallardir.

## Muhim: loyiha ildizini aniqlash

1. Jcode/IDE ochgan workspace yoki foydalanuvchi ko‘rsatgan aniq loyiha papkasini aniqlagin.
2. `~/`, home papka yoki butun diskni loyiha deb qabul qilib, avtomatik indekslama qilma.
3. Agar workspace loyiha papkasi bo‘lmasa, haqiqiy loyiha yo‘lini aniqlamaguncha indekslama va loyiha xotirasini boshlama.
4. `projectmem` hali sozlanmagan bo‘lsa, mavjud `.projectmem/` fayllarini tekshir. Faqat yangi loyiha ildizida, foydalanuvchi vazifasiga mos bo‘lsa, `pjm init`ni bir marta ishlat. Mavjud xotira fayllarini ko‘rmasdan ustidan yozma.

## Kod va indeks qachon yangilanadi?

### Local Git loyihasi

- `git push` qilish shart emas. Indeksator shu kompyuterdagi loyiha fayllarini ko‘radi.
- Dastlab `codebase-memory-mcp`ning `index_repository` vositasi bilan aniq loyiha ildizini bir marta indeksla.
- Muvaffaqiyatli indeksdan keyin, watcher jarayoni ishlayotgan paytda, ro‘yxatdan o‘tgan Git loyihasidagi commit qilinmagan local o‘zgarishlarni ham kuzatishi mumkin. Har bir kichik kod o‘zgarishidan keyin agent qo‘lda to‘liq indekslashni qayta chaqirmasin. Avval `index_status` bilan `watch` holatini tekshir.

### Git ishlatmaydigan papka

Oddiy papkani ham qo‘lda indekslash mumkin. Lekin avtomatik file watcher odatiy sozlamada Git’siz papkalarni kuzatmaydi. Bunday loyiha uchun `watch_non_git=true`ni faqat kerakli muhitda ongli ravishda yoqish yoki o‘zgarishlardan so‘ng `index_repository`ni qo‘lda qayta chaqirish kerak. Sozlama global bo‘lishi mumkinligini tekshir.

### Kod boshqa serverda bo‘lsa

Indeksator faqat o‘zi ishlayotgan mashinada ko‘ra oladigan fayllarni indekslaydi. Agent localda kod yozib, MCP server esa boshqa serverda ishlasa, remote grafik o‘zgarishni ko‘rmaydi, toki fayllar serverga sinxronlanmaguncha. Muqobil yo‘llar:

- agent va MCP vositalarini kod joylashgan bitta serverda ishlatish;
- local fayllarni serverdagi kuzatiladigan loyiha papkasiga xavfsiz sinxronlash;
- kod joylashgan workspace’ni agentga remote tarzda ochish.

Faqat GitHub’ga push qilish talab emas. Biroq sherik local kodingizni ko‘rishi uchun kod yoki muhim hujjatlar unga umumiy kanal orqali yetkazilishi kerak.

## Har bir loyiha sessiyasidagi ish tartibi

### 1. Ishni boshlashdan oldin

- Loyiha ildizini tekshir.
- `projectmem` mavjud bo‘lsa `get_instructions`, `get_summary` va `get_project_map`ni o‘qi. Muammo bilan bog‘liq aniq issue bo‘lsa, `get_issue` bilan tekshir.
- O‘zgartirmoqchi bo‘lgan fayl bo‘yicha `precheck_file` yoki `precheck_files`ni chaqir. U avvalgi muvaffaqiyatsiz yo‘l yoki ochiq muammoni ko‘rsatsa, uni hisobga ol.
- Arxitektura savoliga kerak bo‘lsa `codebase-memory-mcp`ning `index_status`, `search_graph`, `query_graph`, `trace_path` yoki boshqa mos vositasidan foydalan. Indeks holati yo‘q yoki eski bo‘lsa, avval buni aniq bildir.

### 2. Kodni o‘zgartirish

- Faqat foydalanuvchi vazifasiga tegishli fayllarni o‘zgartir.
- Mavjud kod uslubi va testlarni saqla.
- Kodni yozishdan oldin taxminlarni fakt sifatida xotiraga kiritma.
- Muhim qaror bo‘lsa, nima uchun tanlanganini `projectmem`ga yoz.

### 3. Xato yoki muvaffaqiyatsiz urinish yuz bersa

AI tasdiqlangan xato yo‘lni xotiraga yozish uchun dalilga tayanishi kerak. Xato yo‘lni faqat taxmin qilib, uni fakt sifatida saqlama.

- qaysi usul yoki buyruq sinab ko‘rildi;
- aniq test/buyruq xatosi nima edi;
- tekshiruvdan so‘ng ma’lum bo‘lgan sabab nima;
- qaysi shart sabab bu yo‘l ishlamasligi;
- qayta urinmaslik uchun nimani tekshirish kerak.

MCP mavjud bo‘lsa, issue oldindan ochilmaganida avval `log_issue`, keyin `record_attempt`ni chaqir. Mavjud issue bo‘lsa, `record_attempt`ni unga bog‘la va urinish natijasini `failed` deb belgila. MCP mavjud bo‘lmasa, projectmem CLI uchun namuna:

```bash
pjm attempt "Usul X ishlamadi. Buyruq/test: ... Xato: ... Tasdiqlangan sabab: ..." --failed --auto-issue
```

Faqat taxmin bo‘lsa, uni “tekshirilmagan taxmin” deb belgilagin. Uni tasdiqlangan xato yoki loyiha qoidasi sifatida yozma. Logga token, parol, API key, shaxsiy ma’lumot yoki to‘liq maxfiy loglarni kiritma.

### 4. Tuzatish va yakun

- Muammo tuzatilgach, `projectmem`ning `record_fix` vositasida yoki CLI orqali sabab, yechim va tekshiruv natijasini yoz:

```bash
pjm fix "Sabab: ... Tuzatish: ... Tekshiruv: ..."
```

- Tegishli test/build/lint’ni bajar. Qaysi tekshiruv o‘tdi yoki o‘tmaganini foydalanuvchiga ayt.
- Dastlabki indeksdan keyin watcher ishlayotgan bo‘lsa, grafik yangilanishini `index_status` bilan tasdiqla. Watcher yo‘q bo‘lsa, sababini ayt va `index_repository` bilan kerakli loyihani yangila.
- Muhim jamoaviy saboq bo‘lsa, `docs/known-failures.md`, ADR yoki tegishli loyiha hujjatiga qisqa, tekshirilgan xulosa qo‘sh.

## Sherik bilan xotirani bo‘lishish

`projectmem` odatiy sozlamada `.projectmem/summary.md`, `.projectmem/PROJECT_MAP.md`, `.projectmem/AI_INSTRUCTIONS.md` va `.projectmem/issues/` kabi ixcham bilim fayllarini Git orqali ulashishga tayyorlaydi. Xom `.projectmem/events.jsonl` jurnal odatda Git’da yashiriladi. Shu sababli sherik xom logni avtomatik olmaydi.

- Sherik ko‘rishi kerak bo‘lgan muhim saboqni umumiy Markdown hujjatiga yoki tekshirilgan projectmem xulosa fayliga yoz.
- Jamoa qoidalariga muvofiq, ko‘rib chiqilgandan keyin kerakli hujjatlarni commit/push qil. Agent foydalanuvchi ruxsatisiz commit yoki push qilmasin.
- Xom event logni ulashish zarur bo‘lsa, avval maxfiy ma’lumotlarni tekshir. Ikki sherik bir vaqtda logga yozsa merge masalasi chiqishi mumkin.
- `codebase-memory-mcp` grafigi odatda har bir kompyuterda alohida indekslanadi. Sherik o‘z local clone/workspace’ida `index_repository`ni bajarishi kerak.

## Har bir agentni sozlash: ikki alohida qatlam

**MCP sozlamasi** agent client’ga server tool’larini ulaydi. **Loyiha qoidalari** esa agentga bu tool’larni qachon va qanday ishlatishni aytadi. Faqat MCP server qo‘shish tool’larni ko‘rinadigan qiladi, lekin agent har vazifada ulardan albatta foydalanishini kafolatlamaydi. Faqat ushbu guide berilsa, MCP server bo‘lmagani uchun tool chaqirib bo‘lmaydi. Demak, ikkalasini ham sozlash kerak.

1. Client’ning MCP config fayliga `projectmem` va `codebase-memory-mcp` serverlarini `mcpServers` ichiga qo‘sh.
2. Ushbu guide’dagi qisqa **Mandatory agent contract** bo‘limini agent o‘qiydigan loyiha qoidalari fayliga qo‘sh.
3. Mavjud JSON yoki qoida faylini ustidan yozma. Kerakli bo‘limlarni unga birlashtir.
4. Agent client’ni qayta ishga tushir yoki MCP konfiguratsiyasini reload qil, keyin ikkala server ulanishini tekshir.

### Ko‘p ishlatiladigan MCP config fayl yo‘llari

Quyidagi yo‘llar 2026-11-22 holatidagi misollar. Client, operatsion tizim va versiyaga qarab farq qilishi mumkin. Ishlatishdan oldin client’ning rasmiy hujjatini tekshir.

| Agent | Global MCP server config | Workspace MCP config | Agent qoidalari/instruction fayli |
|---|---|---|---|
| Jcode | `~/.jcode/mcp.json` | `.mcp.json` | `~/AGENTS.md` yoki `<project>/AGENTS.md` |
| Google Antigravity App/CLI | `~/.gemini/config/mcp_config.json` | `<workspace>/.agents/mcp_config.json` | `AGENTS.md`, `GEMINI.md` yoki `.agents/rules/*.md` |
| Gemini CLI | `~/.gemini/settings.json` | `<project>/.gemini/settings.json` | `~/.gemini/GEMINI.md` yoki loyiha `GEMINI.md` |
| Boshqa agent | Client’ning rasmiy MCP hujjatini tekshir | Client’ning rasmiy MCP hujjatini tekshir | Client qaysi instruction faylni o‘qishini tekshir |

Local `stdio` serverlar uchun umumiy namuna quyidagi JSON. Absolyut yo‘llarni shu host’dagi haqiqiy executable yo‘llariga almashtir. Jcode, Antigravity va Gemini CLI’da `command` + `args` ishlatiladi. Mavjud config fayliga faqat kerakli `mcpServers` yozuvlarini birlashtir.

```json
{
  "mcpServers": {
    "projectmem": {
      "command": "/ABSOLUTE/PATH/TO/python",
      "args": ["-m", "projectmem.mcp_server"]
    },
    "codebase-memory-mcp": {
      "command": "/ABSOLUTE/PATH/TO/codebase-memory-mcp",
      "args": []
    }
  }
}
```

Remote MCP config sintaksisi client’lar orasida farq qiladi. Jcode’da `type: "http"` va `url`, Antigravity’da `serverUrl`, Gemini CLI’da Streamable HTTP uchun `httpUrl` ishlatish mumkin. Maxfiy tokenni ushbu guide yoki umumiy repository’ga yozma. Antigravity CLI remote ulanishida Streamable HTTP talab qilinadi, legacy HTTP+SSE qo‘llanmaydi.

### Ulanishni tekshirish

- Jcode: `jcode mcp list` ishlat, keyin har bir server uchun `jcode mcp test <server-name>` bajar.
- Antigravity CLI: prompt ichida `/mcp` ochib, server holatini tekshir yoki config’ni reload qil.
- Gemini CLI: `gemini mcp list` bajar.

## Local va remote MCP ulanishi

### Local stdio

Agent MCP serverlarni o‘z kompyuterida subprocess sifatida ishga tushiradi. Kod va tools bir mashinada bo‘lsa, yuqoridagi umumiy JSON namunani client’ning MCP config fayliga qo‘sh va executable’larning mutlaq yo‘llarini ko‘rsat. `PATH` bor deb taxmin qilma.

### Remote MCP gateway

Bitta remote gateway ishlatilsa, u **ikkala** backend MCP serverini ulashi va loyihaning to‘g‘ri workspace’iga yo‘naltirishi kerak. Gateway faqat `projectmem`ni ishga tushirsa, `codebase-memory-mcp` ham ulangan deb hisoblama. Health endpoint javobi yetarli sinov emas. MCP `initialize` va `tools/list` orqali ikkala serverning vositalari ko‘rinishini tekshir.

- Internet orqali ulanishda HTTPS va autentifikatsiya ishlat. Bearer tokenni bu faylga, repoga yoki chat logiga yozma.
- Portni internetga ochishdan ko‘ra VPN yoki ishonchli private network’ni afzal ko‘r.
- Har bir client’ning remote MCP config kaliti farq qilishi mumkin. Masalan, Jcode va Antigravity uchun bir xil JSON kalitlarini avtomatik ravishda ko‘chirib ishlatma.
- Google Antigravity CLI uchun remote MCP Streamable HTTP endpoint kerak. Faqat legacy HTTP+SSE endpoint beradigan gateway u bilan ulanmasligi mumkin. Bir nechta agentda ishlatish maqsad bo‘lsa, gateway transportini oldindan tekshir.

## Agent konfiguratsiyasi va ushbu faylni ishlatish

Desktop’ta saqlangan yo‘riqnoma agentga o‘z-o‘zidan yuklanmaydi. Agent bu fayldan foydalanishi uchun:

1. Uni so‘rov bilan birga biriktir yoki agentga aniq o‘qit.
2. Yoki tegishli loyiha ildizidagi mavjud `AGENTS.md`, `GEMINI.md`, `CLAUDE.md` yoki shu agent qo‘llaydigan rules fayliga `Mandatory agent contract` qismini qo‘sh. Mavjud faylni ustidan yozma, mazmunini birlashtir.
3. Antigravity’da `AGENTS.md` va `GEMINI.md` workspace doirasida doimiy qoidalar sifatida o‘qiladi. Yoki `.agents/rules/mcp-memory.md` nomli qisqa qoida faylini yaratib, quyidagi ko‘rsatmani yoz:

```markdown
---
trigger: always_on
---

For code tasks, follow the project's MCP memory and codebase workflow. Before editing, check the project root, read projectmem instructions and summary, and precheck files. After an observed command/test failure, record evidence and the verified reason. After a verified fix, record the fix and test result. Use codebase-memory-mcp only after checking the correct project index.
```

4. Antigravity’da `always_on` qoidasi har bir so‘rovda faol bo‘ladi, shuning uchun uni qisqa saqla. To‘liq guide’ni har safar prompt’ga qo‘shish o‘rniga workspace’ga `MCP_AGENT_MEMORY_CODEBASE_GUIDE.md` nomi bilan nusxalab, batafsil qoida uchun `model_decision` trigger’idan foydalan. Masalan:

```markdown
---
trigger: model_decision
description: "Use when exploring, editing, or debugging a project that uses projectmem or codebase-memory-mcp."
---

Read `MCP_AGENT_MEMORY_CODEBASE_GUIDE.md` in this workspace and follow it before code changes.
```

5. Gemini CLI va boshqa agentlarda shu client o‘qiydigan loyiha qoidalari faylidan foydalan. Gemini CLI’da qoida va loyiha konteksti `GEMINI.md`ga yoziladi.
6. MCP config o‘zgargach, agentni qayta ishga tushir yoki sozlamani reload qil. Tool ro‘yxati va serverlar ulanishini tekshir.

## Yakuniy nazorat ro‘yxati

- [ ] To‘g‘ri loyiha ildizi aniqlandi, home/butun disk indekslanmadi.
- [ ] Agent yo‘riqnoma va loyiha xotirasini o‘qidi.
- [ ] `projectmem` va `codebase-memory-mcp` ulanishlari alohida tasdiqlandi.
- [ ] Kod o‘zgarishi tegishli test bilan tekshirildi.
- [ ] Birinchi indeks bajarildi, watcher holati tekshirildi yoki nima uchun manual reindex kerakligi qayd etildi.
- [ ] Tasdiqlangan muvaffaqiyatsiz urinish va yechim xotiraga yozildi.
- [ ] Jamoa uchun kerakli saboq umumiy hujjatga qo‘shildi.
- [ ] Hech qanday secret, commit, push yoki zararli o‘zgarish ruxsatsiz bajarilmadi.

## Agent o‘qishi kerak bo‘lgan rasmiy hujjatlar

Versiya va config o‘zgarishi mumkin. O‘rnatish paytida quyidagi rasmiy hujjatlarning yangisini tekshir:

- Projectmem README, Tutorial va Security Policy.
- Codebase Memory MCP Configuration va install yo‘riqnomasi.
- Foydalanilayotgan coding agentning MCP config va project rules yo‘riqnomasi.

---

**Amaliy xulosa:** Agent kodni o‘zgartiradi. `codebase-memory-mcp` kod bog‘liqliklari grafigini indekslaydi va sozlangan bo‘lsa yangilaydi. `projectmem` esa tasdiqlangan xato yo‘llar, sabablar, qarorlar va yechimlarni eslab qoladi. Jamoa ko‘rishi kerak bo‘lgan bilimni umumiy, Git orqali ulashiladigan hujjatga yozish kerak.
