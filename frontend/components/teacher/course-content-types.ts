export const courseContentTypes = [
  {
    id: "video",
    title: "Video",
    text: "Dars videosi. O‘quvchi kurs ichida ko‘radi.",
    accept: "video/*",
    button: "Video yuklash",
  },
  {
    id: "text",
    title: "Matn",
    text: "O‘qiladigan matn yoki qo‘llanma.",
    accept: ".txt,.md,.pdf",
    button: "Matn yuklash",
  },
  {
    id: "voice",
    title: "Ovozli tushuntirish",
    text: "Audio bilan tushuntirish.",
    accept: "audio/*",
    button: "Ovoz yuklash",
  },
  {
    id: "test",
    title: "Test",
    text: "Kurs ichidagi mashq testi.",
    accept: "",
    button: "Test qo‘shish",
  },
  {
    id: "image",
    title: "Rasmli material",
    text: "Sxema, diagramma yoki rasm.",
    accept: "image/*",
    button: "Rasm yuklash",
  },
  {
    id: "presentation",
    title: "Prezentatsiya",
    text: "Slayd ko‘rinishida ko‘rsatish.",
    accept: ".ppt,.pptx,.pdf",
    button: "Prezentatsiya yuklash",
  },
  {
    id: "word",
    title: "Word",
    text: "Word hujjati ko‘rinishida.",
    accept: ".doc,.docx",
    button: "Word yuklash",
  },
  {
    id: "excel",
    title: "Excel",
    text: "Jadval va hisob-kitob fayli.",
    accept: ".xls,.xlsx,.csv",
    button: "Excel yuklash",
  },
  {
    id: "pdf",
    title: "PDF",
    text: "Kitob yoki qo‘llanma PDF.",
    accept: ".pdf",
    button: "PDF yuklash",
  },
] as const;

export type CourseContentTypeId = (typeof courseContentTypes)[number]["id"];