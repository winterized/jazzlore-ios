import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.jazzlore.musicians',
  appName: 'Jazz Musicians',
  webDir: 'www',
  plugins: {
    // Route window.fetch through native HTTP (URLSession). Musicians is the
    // only app with a backend; from capacitor://localhost the BFF
    // (musicians.jazzlore.com) is cross-origin and sends no CORS headers, so a
    // WebView fetch would be blocked. CapacitorHttp bypasses WebView CORS. The
    // app targets the absolute BFF origin only in the native shell
    // (isNativeApp() in useMusicianData.ts).
    CapacitorHttp: {
      enabled: true,
    },
    SplashScreen: {
      launchShowDuration: 500,
      launchAutoHide: false,
      launchFadeOutDuration: 200,
      backgroundColor: '#0a0a0a',
      showSpinner: false,
    },
  },
};

export default config;
