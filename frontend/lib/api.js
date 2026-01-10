import axios from "axios";

const api = axios.create({
  baseURL:
    process.env.NODE_ENV === "production"
      ? ""                              // Browser → same origin
      : process.env.NEXT_PUBLIC_API_URL // SSR / Node
});

export default api;
