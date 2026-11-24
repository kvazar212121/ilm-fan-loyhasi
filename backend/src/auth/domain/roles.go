package domain

import "strings"

// Role constants aligned across Web (Next.js) and Mobile (Flutter) clients.
const (
	RoleTeacher           = "teacher"           // Sertifikat ustozi (web alias: cert-teacher)
	RoleTeacherMaterials  = "teacherMaterials"  // Qo'llanma ustozi (web alias: guide-teacher)
	RoleStudent           = "student"           // Abituriyent (web alias: applicant)
	RoleSchoolStudent     = "schoolStudent"     // Maktab o'quvchisi (web alias: pupil)
	RoleUniversityStudent = "universityStudent" // Talaba
)

var roleAliases = map[string]string{
	"teacher":           RoleTeacher,
	"cert-teacher":      RoleTeacher,
	"teachermaterials":  RoleTeacherMaterials,
	"teacher_materials": RoleTeacherMaterials,
	"guide-teacher":     RoleTeacherMaterials,
	"student":           RoleStudent,
	"applicant":         RoleStudent,
	"schoolstudent":     RoleSchoolStudent,
	"school_student":    RoleSchoolStudent,
	"pupil":             RoleSchoolStudent,
	"universitystudent": RoleUniversityStudent,
	"university_student": RoleUniversityStudent,
}

// NormalizeRole accepts canonical role IDs (Flutter) and Web aliases and returns
// the canonical role ID.
func NormalizeRole(raw string) (string, bool) {
	key := strings.ToLower(strings.TrimSpace(raw))
	canonical, ok := roleAliases[key]
	return canonical, ok
}
