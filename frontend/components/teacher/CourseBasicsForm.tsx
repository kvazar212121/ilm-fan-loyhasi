"use client";

import { useState, type FormEvent } from "react";

export function CourseBasicsForm() {
  const [title, setTitle] = useState("");
  const [subject, setSubject] = useState("");
  const [about, setAbout] = useState("");

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
  }

  return (
    <form
      onSubmit={onSubmit}
      className="flex flex-col gap-2 rounded-2xl border border-line bg-white p-5"
    >
      <h2 className="text-lg font-semibold">Kurs haqida</h2>
      <input
        value={title}
        onChange={(event) => setTitle(event.target.value)}
        placeholder="Kurs nomi"
        className="rounded-2xl border border-line px-4 py-3 text-sm outline-none focus:border-accent"
      />
      <input
        value={subject}
        onChange={(event) => setSubject(event.target.value)}
        placeholder="Fan"
        className="rounded-2xl border border-line px-4 py-3 text-sm outline-none focus:border-accent"
      />
      <textarea
        value={about}
        onChange={(event) => setAbout(event.target.value)}
        placeholder="Qisqa tavsif"
        rows={3}
        className="resize-none rounded-2xl border border-line px-4 py-3 text-sm outline-none focus:border-accent"
      />
      <p className="text-xs text-ink/55">
        Saqlash keyin backend bilan ulanadi. Materiallar shu kurs ichida o‘quvchiga ko‘rinadi.
      </p>
    </form>
  );
}