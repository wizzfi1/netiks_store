import nextCoreWebVitals from "eslint-config-next/core-web-vitals";
import nextTypeScript from "eslint-config-next/typescript";

const eslintConfig = [
  ...nextCoreWebVitals,
  ...nextTypeScript,
  {
    rules: {
      // Next.js server components use try/catch around data fetching, not rendering.
      // The JSX inside is intentional and this pattern is safe in RSC.
      "react-hooks/error-boundaries": "off",
    },
  },
];

export default eslintConfig;
