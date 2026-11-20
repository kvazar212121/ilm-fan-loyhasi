import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  allowedDevOrigins: ["sat-ilmfan.gvazar.uz", "92.5.51.110"],
  cacheComponents: true,
  partialPrefetching: true,
  turbopack: {
    rules: {
      "*.css": {
        loaders: ["@tailwindcss/turbopack"],
        as: "*.css",
      },
    },
  },
};

export default nextConfig;
