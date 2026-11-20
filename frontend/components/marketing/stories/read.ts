import type { SectionStory } from "@/components/marketing/types";

export const textbookStory: SectionStory = {
  art: "book",
  eyebrow: "Bo‘lim taqdimoti",
  title: "Darsliklar",
  lead: "Darslik — o‘quvchi o‘zi, o‘z tezligida o‘qiydigan kitob. U fanni boshidan oxirigacha bobma-bob beradi: tushuncha, misol, xulosa va keyingi bobga o‘tish.",
  purpose:
    "Mustaqil o‘qiydigan odamga tarqoq eslatma yetmaydi. Unga sahifa tartibi kerak. Abituriyent bir nechta fan olgan bo‘lsa, har bir fan o‘z darsligiga ega bo‘ladi. Oddiy o‘quvchi fan tanlamaydi: ustoz belgilagan kitobni ochadi va shu tartibda o‘qiydi. Darslik testni almashtirmaydi. U avval tushuntiradi, test keyin tekshiradi.",
  benefits: [
    {
      title: "Ketma-ket o‘qish",
      text: "Boblar tartibi buzilmaydi. Keyingi sahifa oldingisiga tayanadi.",
    },
    {
      title: "O‘z tezligi",
      text: "Sinf jadvalini kutmasdan, to‘xtab, qaytib, davom etish mumkin.",
    },
    {
      title: "To‘liq poydevor",
      text: "Qisqa video eslatma beradi. Darslik esa qoidaning o‘zini ochadi.",
    },
    {
      title: "Bir nechta fan",
      text: "Abituriyent tanlagan har bir fan uchun alohida kitob yo‘li bor.",
    },
  ],
  gives: [
    {
      title: "O‘qish yo‘li",
      text: "Fan bo‘yicha boshidan oxirigacha yuriladigan matn.",
    },
    {
      title: "Dars oralig‘idagi tayyorgarlik",
      text: "Keyingi darsdan oldin bobni o‘qib chiqish mumkin.",
    },
    {
      title: "Test uchun zamin",
      text: "Yechishdan oldin qoida va misol shu kitobda turadi.",
    },
  ],
  steps: [
    { title: "Kirish", text: "Hisob ochilgach darsliklar ro‘yxati shu odamning roliga mos keladi." },
    { title: "Fan", text: "Abituriyent o‘z fanlarini ko‘radi. O‘quvchi o‘ziga berilgan kitobni ochadi." },
    { title: "Bob", text: "Sahifa o‘qiladi, keyin shu mavzuning testi ochiladi." },
  ],
};

export const reelStory: SectionStory = {
  art: "reel",
  eyebrow: "Bo‘lim taqdimoti",
  title: "Reels",
  lead: "Reels — qisqa video dars. Bitta lavhada bitta fikr: formula, qoida yoki tez-tez uchraydigan xato. Lenta pastga yuradi, keraklisi to‘xtatiladi, keyin shu mavzuning to‘liq sahifasiga o‘tiladi.",
  purpose:
    "Uzun darsni hozir ochishga vaqt bo‘lmasa ham, bir daqiqalik eslatma mavzuni ushlab turadi. Reels darslikni almashtirmaydi. U eshik: qiziqtiradi, eslatadi va to‘liq materialga olib boradi. Ustoz o‘z fanidan qisqa lavha qo‘yadi. O‘quvchi esa o‘z lentasidan kerakli lavhani topadi.",
  benefits: [
    {
      title: "Bitta fikr",
      text: "Lavha cho‘zilmaydi. Bir qoida, bir misol, bir ogohlantirish.",
    },
    {
      title: "Tez eslatma",
      text: "Imtihon oldidan yoki dars oralig‘ida qisqa takror bo‘ladi.",
    },
    {
      title: "To‘liq sahifaga yo‘l",
      text: "Video tugagach, shu mavzuning darsligi va testi ochiladi.",
    },
    {
      title: "Telefonda qulay",
      text: "Katta ekran shart emas. Lenta qo‘lda ko‘riladi.",
    },
  ],
  gives: [
    {
      title: "Qisqa xotira",
      text: "Uzoq matnni ochishdan oldin mavzu bir daqiqada esga tushadi.",
    },
    {
      title: "Ustoz ovozi",
      text: "Yozma dars yonida qisqa tushuntirish lavhasi turadi.",
    },
    {
      title: "Keyingi qadam",
      text: "Ko‘rib bo‘lgach o‘qish yoki testga o‘tish aniq bo‘ladi.",
    },
  ],
  steps: [
    { title: "Tomosha", text: "Lentani kirishsiz ko‘rasiz. Layk va boshqa bosishlar uchun kirish kerak." },
    { title: "Lavha", text: "Pastga yurib, kerakli qoidani to‘xtatib ko‘rasiz." },
    { title: "Davom", text: "Shu mavzuning darsligi yoki testi ochiladi." },
  ],
};
