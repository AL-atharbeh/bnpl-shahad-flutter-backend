import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Rewrite API requests to backend
  async rewrites() {
    return [
      {
        source: '/api/v1/:path*',
        destination: 'https://api.shahedapp.com/api/v1/:path*',
      },
    ];
  },
};

export default nextConfig;
