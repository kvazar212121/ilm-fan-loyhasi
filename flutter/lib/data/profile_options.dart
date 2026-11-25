const uzRegions = <String>[
  'Toshkent shahri',
  'Toshkent viloyati',
  'Andijon viloyati',
  'Buxoro viloyati',
  'Farg‘ona viloyati',
  'Jizzax viloyati',
  'Namangan viloyati',
  'Navoiy viloyati',
  'Qashqadaryo viloyati',
  'Qoraqalpog‘iston Respublikasi',
  'Samarqand viloyati',
  'Sirdaryo viloyati',
  'Surxondaryo viloyati',
  'Xorazm viloyati',
];

class GenderOption {
  const GenderOption({required this.id, required this.label});

  final String id;
  final String label;
}

const genderOptions = <GenderOption>[
  GenderOption(id: 'male', label: 'Erkak'),
  GenderOption(id: 'female', label: 'Ayol'),
];
