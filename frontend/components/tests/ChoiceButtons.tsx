import type { PublicChoice } from "@/lib/quiz/types";

type ChoiceButtonsProps = {
  choices: PublicChoice[];
  pickedId: string | null;
  correctId: string | null;
  revealed: boolean;
  disabled: boolean;
  showCounts: boolean;
  onPick: (choiceId: string) => void;
};

export function ChoiceButtons({
  choices,
  pickedId,
  correctId,
  revealed,
  disabled,
  showCounts,
  onPick,
}: ChoiceButtonsProps) {
  return (
    <div className="grid gap-2">
      {choices.map((choice, index) => {
        const letter = String.fromCharCode(65 + index);
        const isCorrect = revealed && choice.id === correctId;
        const isWrong = revealed && pickedId === choice.id && choice.id !== correctId;
        const isPicked = !revealed && pickedId === choice.id;
        const tone = isCorrect
          ? "border-accent bg-accent text-white"
          : isWrong
            ? "border-red-700 bg-red-50 text-red-900"
            : isPicked
              ? "border-accent bg-white"
              : "border-line bg-white";
        return (
          <button
            key={choice.id}
            type="button"
            disabled={disabled}
            onClick={() => onPick(choice.id)}
            className={`flex items-center justify-between gap-3 rounded-2xl border px-4 py-3 text-left text-sm font-medium disabled:cursor-default ${tone}`}
          >
            <span>
              {letter}. {choice.text}
            </span>
            {showCounts ? <span className="text-xs opacity-80">{choice.count}</span> : null}
          </button>
        );
      })}
    </div>
  );
}
