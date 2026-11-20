import type { SectionStory } from "@/components/marketing/types";

export const testStory: SectionStory = {
  art: "quiz",
  eyebrow: "Bo‘lim taqdimoti",
  title: "Testlar",
  lead: "Test — o‘qigan narsa yodda qolganini tekshirish joyi. Bu yerda uch xil ish bor. Yolg‘iz mashq. Hamma bilan bir vaqtda yechiladigan xona. Auditoriya ekranida birinchi to‘g‘ri javob ball oladigan musobaqa.",
  purpose:
    "O‘qish bilishni ko‘rsatmaydi. Test xatoni darhol ko‘rsatadi. Individual rejimda javob belgilangach to‘g‘ri variant shu joyida ochiladi. Jonli rejimda savol hammaga birga tushadi, belgilangan soniya tugagach kim to‘g‘ri, kim xato ekani sanaladi. Auditoriya rejimida ustoz test tuzadi, linkni ekranga qo‘yadi, o‘quvchilar telefondan javob beradi va birinchi to‘g‘ri topgan kishi ball oladi.",
  benefits: [
    {
      title: "Yolg‘iz mashq",
      text: "O‘z vaqtida yechiladi. Javob ochilishi boshqa odamni kutmaydi.",
    },
    {
      title: "Birga, bir vaqt",
      text: "Savol hammaga birga tushadi. Vaqt tugagach to‘g‘ri va xato soni ko‘rinadi.",
    },
    {
      title: "Auditoriya poygasi",
      text: "Ekrandagi link. Telefonlardan javob. Birinchi to‘g‘ri javob ball oladi.",
    },
    {
      title: "Javob yashirin",
      text: "To‘g‘ri variant javob berilmaguncha yoki vaqt tugamaguncha ochilmaydi.",
    },
  ],
  gives: [
    {
      title: "Aniq xato",
      text: "Qaysi savol yechilmagani taxmin emas, belgi bilan ko‘rinadi.",
    },
    {
      title: "Sinf kayfiyati",
      text: "Jonli xona va auditoriya musobaqasi darsni o‘yin shaklida tekshiradi.",
    },
    {
      title: "Ustoz nazorati",
      text: "Auditoriya testini ustoz tuzadi, ekranni o‘zi boshqaradi.",
    },
  ],
  steps: [
    { title: "Kirish", text: "Ism va rol saqlangach testga o‘z nomingiz bilan kiriladi." },
    { title: "Rejim", text: "Yolg‘iz, jonli xona yoki auditoriya tanlanadi." },
    { title: "Natija", text: "To‘g‘ri javob, ball va keyingi savol shu yerda ochiladi." },
  ],
};

export const courseStory: SectionStory = {
  art: "course",
  eyebrow: "Bo‘lim taqdimoti",
  title: "Kurslar",
  lead: "Kurs — bir necha darsni bitta yo‘lga yig‘ish. Tashkilotchi mavzu, dars va materialni ketma-ket qo‘yadi. O‘quvchi bugun nima qilishni izlamaydi: navbatdagi dars ochiladi.",
  purpose:
    "Tarqoq video va test hali kurs emas. Kursning boshlanishi, darslar tartibi va tugashi bor. Ustoz yoki tashkilotchi shu tartibni bir marta yig‘adi, guruh shu tartibda yuradi. Har bir darsda matn, qisqa video yoki test turishi mumkin. Shunday qilib tayyorlov bir kunlik mashq emas, bir necha haftalik yo‘l bo‘ladi.",
  benefits: [
    {
      title: "Dars tartibi",
      text: "Birinchi dars tugamasdan keyingisi adashib ochilmaydi.",
    },
    {
      title: "Bitta guruh, bitta yo‘l",
      text: "Hamma o‘quvchi bir xil ketma-ketlikni ko‘radi.",
    },
    {
      title: "Material dars ichida",
      text: "Video, matn va test alohida sahifalarda yo‘qolmaydi.",
    },
    {
      title: "Tashkilotchi boshqaradi",
      text: "Kursni ochgan odam dars qo‘shadi va tartibni o‘zgartiradi.",
    },
  ],
  gives: [
    {
      title: "Bir necha haftalik yo‘l",
      text: "Imtihon yoki semestr oldidan kunma-kun yuriladigan reja.",
    },
    {
      title: "Bugungi dars",
      text: "O‘quvchi ro‘yxatdan o‘z navbatini ko‘radi.",
    },
    {
      title: "Guruh intizomi",
      text: "Kim qaysi darsda ekani ustozga tushunarli bo‘ladi.",
    },
  ],
  steps: [
    { title: "Kirish", text: "Tashkilotchi yoki o‘quvchi o‘z roli bilan kiradi." },
    { title: "Kurs", text: "Yo‘l tanlanadi yoki yangi kurs yig‘iladi." },
    { title: "Dars", text: "Navbatdagi material ochiladi va shu darsning mashqi bajariladi." },
  ],
};
