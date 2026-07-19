# White Noise Source Candidates

Checked on 2026-07-19.

Prefer Creative Commons 0 sources for bundled app audio. Freesound original-quality downloads usually require a free login/OAuth download flow, but the sound pages expose license, duration, format, and technical metadata for review.

## Recommended CC0 Candidates

| App asset | Scene | Recommended source | License | Duration / format | Loop note |
| --- | --- | --- | --- | --- | --- |
| `ocean.m4a` | 沙滩海声 | Freesound: Gentle Ocean Waves Loop by kkenny101, https://freesound.org/people/kkenny101/sounds/852826/ | CC0 | 0:21 WAV, 48 kHz, mono | Source says seamless loop of gentle beach waves. Best fit for a compact app bundle. |
| `fireplace.m4a` | 壁炉柴火 | Freesound: Fireplace by myLoop, https://freesound.org/people/myLoop/sounds/852107/ | CC0 | 0:08 WAV, 48 kHz, stereo | Source says perfect loop / seamless loop. Short, but good for subtle fireplace texture. |
| `rain.m4a` | 淅淅雨声 | Freesound: Rain_Loop.wav by Snoopy20111, https://freesound.org/s/399072/ | CC0 | 5:16 WAV, 96 kHz, stereo | Source says simple looping rain, collapsible to mono. Downsample before bundling. |
| `summer-night.m4a` | 虫鸣夏夜 | Freesound: Crickets - Warm Summer Night - Ambient.wav by Speziax, https://www.freesound.org/people/Speziax/sounds/645329/ | CC0 | 1:55 WAV, 44.1 kHz, stereo | Not explicitly marked seamless, but steady ambience should crossfade-loop cleanly after audition. |
| `cafe.m4a` | 咖啡厅环境 | Freesound: People talking at cafe ambience by priesjensen, https://freesound.org/people/priesjensen/sounds/482990/ | CC0 | 2:17 WAV source; bundled from public preview MP3 converted to AAC M4A | User-selected source; cozy outdoor cafe in Copenhagen with people talking. |
| `library.m4a` | 图书馆氛围 | Freesound: Quiet library ambience by xkeril, https://freesound.org/people/xkeril/sounds/620683/ | CC0 | 9:40 WAV, 48 kHz, stereo | Long quiet ambience with page/pen/book/chair/ventilation texture. Trim or compress for bundle size. |

## Backup Candidates

| Scene | Source | License | Why keep as backup |
| --- | --- | --- | --- |
| 沙滩海声 | Freesound: oceanwaves-8.wav by Rmutt, https://freesound.org/people/Rmutt/sounds/149079/ | CC0 | Longer 2:05 edited loop if the shorter ocean file feels repetitive. |
| 壁炉柴火 | Pixabay: Fireplace Fire Crackling - Loop by SoundsForYou, https://pixabay.com/sound-effects/nature-fireplace-fire-crackling-loop-123930/ | Pixabay Content License | 3:00 MP3 loop, easy download route, useful if Freesound login is inconvenient. |
| 淅淅雨声 | Freesound: Rain Loop 3 by richwise, https://freesound.org/people/richwise/sounds/584943/ | CC0 | 4:10 loopable rain, but large 88.2 kHz source. |
| 虫鸣夏夜 | Freesound: Crickets, distant barks summer night.wav by Daphne_in_Wonderland, https://freesound.org/people/Daphne_in_Wonderland/sounds/383477/ | CC0 | Quiet cricket field recording; check distant barks before bundling. |
| 咖啡厅环境 | Freesound: Cafe/Coffee shop by Ultra-Edward, https://freesound.org/people/Ultra-Edward/sounds/823831/ | CC0 | No music, 60 seconds, good if the recommended cafe has too much street/traffic sound. |
| 咖啡厅环境 | Freesound: Cofee shop Ambience .wav by aidansamuel, https://freesound.org/people/aidansamuel/sounds/540299/ | CC0 | 2:16 loopable cafe recording kept as an alternate. |
| 图书馆氛围 | Freesound: Library ambience by xkeril, https://freesound.org/people/xkeril/sounds/613781/ | CC0 | Busier university library ambience if the quiet version feels too subtle. |

## App Integration Notes

- Final bundled filenames should match `Soundscape.assetBaseName`: `ocean`, `fireplace`, `rain`, `summer-night`, `cafe`, `library`.
- Prefer exporting final assets as AAC `.m4a`, 44.1 or 48 kHz, stereo where useful, around 128-192 kbps.
- For large WAV sources, keep masters outside the app bundle and commit only compressed reviewed app assets.
- Before bundling, audition each source for clicks, voices, sirens, coughs, barks, music, and abrupt transient events.
- If a source is steady but not truly seamless, use a short equal-power crossfade at the loop boundary or duplicate/trim a middle section before export.

Example conversion after placing a reviewed WAV master next to this file:

```sh
afconvert -f m4af -d aac -b 160000 ocean.wav ocean.m4a
```
