type MethodIconProps = {
  id: "google" | "telegram" | "phone" | "qr";
};

export function MethodIcon({ id }: MethodIconProps) {
  if (id === "google") {
    return (
      <svg viewBox="0 0 24 24" className="h-5 w-5" aria-hidden>
        <path
          fill="#4285F4"
          d="M23 12.3c0-.8-.1-1.6-.2-2.3H12v4.4h6.2a5.3 5.3 0 0 1-2.3 3.5v2.9h3.7C21.6 18.7 23 15.8 23 12.3z"
        />
        <path
          fill="#34A853"
          d="M12 23c2.9 0 5.4-1 7.2-2.6l-3.7-2.9c-1 .7-2.3 1.1-3.5 1.1-2.7 0-5-1.8-5.8-4.3H2.4v2.9A11 11 0 0 0 12 23z"
        />
        <path
          fill="#FBBC05"
          d="M6.2 14.3a6.6 6.6 0 0 1 0-4.2V7.2H2.4a11 11 0 0 0 0 9.6l3.8-2.5z"
        />
        <path
          fill="#EA4335"
          d="M12 5.4c1.5 0 2.9.5 4 1.5l3-3A11 11 0 0 0 2.4 7.2l3.8 2.9C7 7.2 9.3 5.4 12 5.4z"
        />
      </svg>
    );
  }

  if (id === "telegram") {
    return (
      <svg viewBox="0 0 24 24" className="h-5 w-5" aria-hidden>
        <circle cx="12" cy="12" r="10" fill="#229ED9" />
        <path
          fill="#fff"
          d="M17.2 7.6 6.9 11.6c-.7.3-.7.6-.1.8l2.6.8 1 .3 6.1-3.8c.3-.2.5 0 .3.2l-5 4.5-.2 2.2c.3 0 .4-.1.6-.3l1.4-1.4 2.9 2.2c.5.3.9.1 1-.5l1.8-8.4c.2-.8-.3-1.2-1.1-.8z"
        />
      </svg>
    );
  }

  if (id === "qr") {
    return (
      <svg viewBox="0 0 24 24" className="h-5 w-5 text-accent" fill="none" stroke="currentColor" strokeWidth="1.7" aria-hidden>
        <rect x="3.5" y="3.5" width="6.5" height="6.5" rx="1.2" />
        <rect x="14" y="3.5" width="6.5" height="6.5" rx="1.2" />
        <rect x="3.5" y="14" width="6.5" height="6.5" rx="1.2" />
        <path d="M14 14h2.5v2.5H14zM18 14h2.5v2.5H18zM14 18h2.5v2.5H14zM18 18h2.5v2.5H18z" fill="currentColor" stroke="none" />
      </svg>
    );
  }

  return (
    <svg viewBox="0 0 24 24" className="h-5 w-5" aria-hidden>
      <rect x="7" y="2.5" width="10" height="19" rx="2" fill="none" stroke="currentColor" strokeWidth="1.6" />
      <circle cx="12" cy="18" r="0.8" fill="currentColor" />
    </svg>
  );
}
