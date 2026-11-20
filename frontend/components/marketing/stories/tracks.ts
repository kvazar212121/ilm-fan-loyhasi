import type { SectionStory } from "@/components/marketing/types";

export const certificateStory: SectionStory = {
  art: "prep",
  eyebrow: "Bo‘lim taqdimoti",
  title: "Sertifikatga tayyorlov",
  lead: "Bu yo‘l davlat sertifikati oladigan o‘qituvchi uchun. Avval bitta fan tanlanadi, keyin faqat shu fan bo‘yicha video dars va test ochiladi. Sertifikat saytda berilmaydi: imtihon tashqarida topshiriladi, tayyorgarlik shu yerda yig‘iladi.",
  purpose:
    "Sertifikat imtihoni bitta fan atrofida bo‘ladi. Abituriyentning kirish imtihoni boshqa yo‘l. Ikkalasi aralashsa, o‘qituvchi vaqtini boshqa dasturga sarflaydi. Shu bois sertifikatga tayyorlov alohida: matematika tanlansa, faqat shu fanning darsi va mashqi chiqadi.",
  benefits: [
    {
      title: "Bitta imtihon fani",
      text: "O‘qituvchi sertifikat fanini ochadi va shu ichida qoladi.",
    },
    {
      title: "Dars va test yonma-yon",
      text: "Mavzuni ko‘rib chiqib, darhol shu mavzu bo‘yicha mashq qilish mumkin.",
    },
    {
      title: "Imtihon oldidan sinalish",
      text: "Xato imtihon kunida emas, mashqda ko‘rinadi.",
    },
    {
      title: "Abituriyentdan alohida",
      text: "Kirish imtihoni materiallari bu yerga aralashmaydi.",
    },
  ],
  gives: [
    {
      title: "Sertifikat yo‘li",
      text: "Tanlangan fan bo‘yicha video, izoh va mashq bitta ketma-ketlikda turadi.",
    },
    {
      title: "Qayta ko‘rish",
      text: "Qaysi mavzu ochiq, qaysi mavzuni yana ko‘rish kerakligi bilinadi.",
    },
    {
      title: "Imtihon oldi holati",
      text: "Tashqaridagi imtihonga chiqishdan oldin yechimni tekshirasiz.",
    },
  ],
  steps: [
    { title: "Kirish", text: "Telegram, Google yoki telefon raqam bilan hisob ochiladi." },
    { title: "Rol va fan", text: "Sertifikat ustozi tanlanadi va bitta imtihon fani belgilanadi." },
    { title: "Material", text: "Shu fan ichida video dars va test ochiladi." },
  ],
};

export const applicantStory: SectionStory = {
  art: "quiz",
  eyebrow: "Bo‘lim taqdimoti",
  title: "Abituriyent tayyorlovi",
  lead: "Bu yo‘l oliy ta’lim imtihonlariga tayyorlanayotgan abituriyent uchun. U bir nechta fan oladi. Har bir fan bo‘yicha dars va test alohida ochiladi. Sertifikat oladigan o‘qituvchining yo‘li boshqa sahifada.",
  purpose:
    "Abituriyentning imtihoni bitta fanga sig‘maydi. Matematika, ona tili yoki tarix birga kelishi mumkin. Shu bois fanlar ro‘yxati bir nechta. Har bir fan o‘z darsi va o‘z testiga ega. O‘qituvchining sertifikat dasturi bu yerga aralashmaydi, abituriyent o‘z imtihoniga qarab o‘qiydi.",
  benefits: [
    {
      title: "Bir nechta fan",
      text: "Kerakli fanlar birga belgilanadi. Har biri alohida ochiladi.",
    },
    {
      title: "Imtihon bo‘yicha tartib",
      text: "Kirish imtihonining mavzulari sertifikat dasturi bilan aralashmaydi.",
    },
    {
      title: "Darsdan mashqqa",
      text: "Mavzuni o‘qib, shu fan testi bilan tekshirish mumkin.",
    },
    {
      title: "O‘z tezligi",
      text: "Abituriyent fanlarni navbatma-navbat, o‘z vaqtida o‘tadi.",
    },
  ],
  gives: [
    {
      title: "Imtihon fanlari",
      text: "Tanlangan har bir fan uchun dars va test yo‘li bor.",
    },
    {
      title: "Bo‘shliqni ko‘rish",
      text: "Qaysi fanda xato ko‘p, shu fan yana ochiladi.",
    },
    {
      title: "Imtihon oldi mashq",
      text: "Rasmiy imtihondan oldin savol shakli bilan tanishiladi.",
    },
  ],
  steps: [
    { title: "Kirish", text: "Telegram, Google yoki telefon raqam bilan hisob ochiladi." },
    { title: "Rol va fanlar", text: "Abituriyent tanlanadi va bir nechta imtihon fani belgilanadi." },
    { title: "Material", text: "Har bir fan ichida dars va test ochiladi." },
  ],
};
