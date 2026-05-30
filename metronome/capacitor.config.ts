import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.jazzlore.metronome',
  appName: 'Jazz Metronome',
  webDir: 'www',
  plugins: {
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
