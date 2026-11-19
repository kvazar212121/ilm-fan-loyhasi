type ReelPipelineProps = {
  step: "idle" | "check" | "format" | "compress" | "done" | "error";
  message?: string;
};

const labels: Record<ReelPipelineProps["step"], string> = {
  idle: "",
  check: "Davomiylik tekshirilmoqda…",
  format: "Kerakli formatga keltirilmoqda…",
  compress: "Sifat saqlangan holda siqilmoqda…",
  done: "Tayyor.",
  error: "",
};

export function ReelPipeline({ step, message }: ReelPipelineProps) {
  if (step === "idle") {
    return null;
  }

  const text = step === "error" ? message : labels[step];

  return (
    <p
      className={`rounded-2xl border px-4 py-3 text-sm ${
        step === "error"
          ? "border-red-300 bg-red-50 text-red-900"
          : "border-line bg-paper text-ink/70"
      }`}
      role="status"
    >
      {text}
    </p>
  );
}