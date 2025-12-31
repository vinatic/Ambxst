# Media packages: video, audio, players
{ pkgs, wrapWithNixGL }:

with pkgs; [
  (wrapWithNixGL gpu-screen-recorder)
  (wrapWithNixGL mpvpaper)

  ffmpeg
  x264
  playerctl

  # Audio
  pipewire
  wireplumber
]
