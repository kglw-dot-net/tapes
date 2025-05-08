import { Controller } from "@hotwired/stimulus"
import { Howl, Howler } from 'howler'

Howler.autoSuspend = false;

export default class extends Controller {
  static targets = [
    "container", "currentTime", "duration", "progress", "trackTitle", "trackSubtitle", "isPlaying", "isPlayingMobile",
    "thumbnail", "mobilePlayer", "mobilePlayerThumbnail", "mobilePlayerBackdrop", "mobilePlayerTrackTitle", 
    "mobilePlayerTrackSubtitle", "mobilePlayerProgress", "mobilePlayerCurrentTime", "mobilePlayerDuration", 
    "mobilePlayerIsPlaying"
  ];

  // Events

  showMobilePlayerUIIfMobile() {
    // If screen width is wider than mobileBreakpointPx, don't show mobile player UI
    if (window.innerWidth > this.mobileBreakpointPx) return;

    this.showMobilePlayerUI();
  }
  
  showMobilePlayerUI() {
    this.mobilePlayerTarget.classList.remove('translate-y-full');
  }

  hideMobilePlayerUI() {
    this.mobilePlayerTarget.classList.add('translate-y-full');
  }

  playPlaylist({ detail: { playlist, trackIdx } }) {
    if (this.playlist.id !== playlist.id) {
      this.resetTrack();

      this.playlist = playlist;

      this.containerTarget.classList.remove('invisible');
      this.containerTarget.classList.remove('opacity-0');

      this.setTrackSubtitle(this.playlist.title);
      this.setImageUrl(this.playlist.thumbnail);
    }

    this.playTrack(trackIdx);
  }

  seek(event) {
    const progressBar = event.currentTarget;

    const currentTrack = this.playlist.tracks[this.currentTrackIdx].howl;

    if (currentTrack == null) return;

    const progressWidth = progressBar.clientWidth;
    const mouseX = event.clientX - progressBar.getBoundingClientRect().left;

    const percent = mouseX / progressWidth;

    currentTrack.seek(this.playlist.tracks[this.currentTrackIdx].duration * percent);

    this.updateTrackPosition();
  }

  playPause() {
    const isPlaying = !this.isPlayingTarget.checked;

    this.setIsPlayingDisplay(isPlaying);

    const currentTrack = this.playlist.tracks[this.currentTrackIdx].howl;

    if (currentTrack == null) return;

    if (isPlaying && !currentTrack.playing())
      currentTrack.play();

    if (!isPlaying && currentTrack.playing())
      currentTrack.pause();
  }

  nextTrack() {
    if (this.currentTrackIdx == this.playlist.tracks.length - 1) return;

    this.playTrack(this.currentTrackIdx + 1);
  }

  previousTrack() {
    if (this.currentTrackIdx == 0) return;

    this.playTrack(this.currentTrackIdx - 1);
  }

  goToCurrentTrackRecording() {
    if (!this.currentTrackIdx) return;

    // window.location.href = this.playlist.tracks[this.currentTrackIdx].recordingUrl;
    window.Turbo.visit(this.playlist.tracks[this.currentTrackIdx].recordingUrl);
  }

  // Internal

  // Called on initial page load only
  initialize() {
    this.mobileBreakpointPx = 1024;
    this.iOS = false;
    this.resetAll();
  }

  // Called on all page loads
  connect() {
    this.setCurrentTrackActive();
  }

  resetTrack() {
    this.setProgressBar();

    this.setCurrentTime("0:00");
    this.setDuration("0:00");

    this.setTrackTitle("");

    this.currentTrackIdx = null;

    this.setIsPlayingDisplay(false);

    if (this.interval) {
      clearInterval(this.interval);
    }
  }

  setIsPlayingDisplay(isPlaying) {
    this.isPlayingTarget.checked = isPlaying;
    this.isPlayingMobileTarget.checked = isPlaying;
    this.mobilePlayerIsPlayingTarget.checked = isPlaying
  }

  setCurrentTime(time) {
    this.currentTimeTarget.textContent = time;
    this.mobilePlayerCurrentTimeTarget.textContent = time;
  }

  setDuration(time) {
    this.durationTarget.textContent = time;
    this.mobilePlayerDurationTarget.textContent = time;
  }

  setProgressBar(value = null) {
    if (!value) {
      this.progressTarget.removeAttribute("value");
      this.progressTarget.classList.remove('progress-primary');

      this.mobilePlayerProgressTarget.removeAttribute("value");
      this.mobilePlayerProgressTarget.classList.remove('progress-primary');
    }
    else {
      this.progressTarget.setAttribute("value", value);
      this.progressTarget.classList.add('progress-primary');

      this.mobilePlayerProgressTarget.setAttribute("value", value);
      this.mobilePlayerProgressTarget.classList.add('progress-primary');
    }
  }

  setTrackTitle(title) {
    this.trackTitleTarget.textContent = title;
    this.mobilePlayerTrackTitleTarget.textContent = title;
  }

  setTrackSubtitle(subtitle) {
    this.trackSubtitleTarget.textContent = subtitle;
    this.mobilePlayerTrackSubtitleTarget.textContent = subtitle;
  }

  resetAll() {
    this.resetTrack();

    this.playlist = {};

    this.setTrackSubtitle("");
    this.setImageUrl("");

    // Invisible is used to prevent click events, opacity-0 is used for fade in/out
    this.containerTarget.classList.add('invisible');
    this.containerTarget.classList.add('opacity-0');
  }

  setImageUrl(url) {
    this.thumbnailTarget.src = url;
    this.mobilePlayerThumbnailTarget.src = url;
    this.mobilePlayerBackdropTarget.src = url;//.style.backgroundImage = `url(${url})`;
  }

  getFormattedTime(seconds) {
    return `${Math.floor(seconds / 60)}:${seconds % 60 < 10 ? '0' : ''}${Math.floor(seconds % 60)}`;
  }

  updateTrackPosition() {
    const currentTrack = this.playlist.tracks[this.currentTrackIdx].howl;
    const duration = this.playlist.tracks[this.currentTrackIdx].duration;

    if (currentTrack == null) {
      if (this.interval) clearInterval(this.interval);
      return;
    }

    // TODO: If not playing, hide timestamp, remove value attribute from progress bar and remove progress-primary class

    let currentTime = currentTrack.seek();

    if (currentTime > duration) currentTime = duration;

    this.setCurrentTime(this.getFormattedTime(currentTime));

    const percentPlayed = currentTime / this.playlist.tracks[this.currentTrackIdx].duration;

    this.setProgressBar(percentPlayed * 100);

    if (navigator.mediaSession)
      navigator.mediaSession.setPositionState({
        duration: duration,
        position: currentTime,
        playbackRate: 1.0
      });
  }

  loadTrack(track, isSubsequentPlay) {
    track.howl = new Howl({
      src: [track.url],
      preload: true,
      html5: !(this.iOS && isSubsequentPlay),

      onload: () => {
        track.duration = track.howl.duration();
      },

      onplay: () => {
        this.setIsPlayingDisplay(true);

        // If there is a next track, load it
        if (this.currentTrackIdx != this.playlist.tracks.length - 1) {
          if (this.playlist.tracks[this.currentTrackIdx + 1].howl == null)
            this.loadTrack(this.playlist.tracks[this.currentTrackIdx + 1], true);

          if (this.playlist.tracks[this.currentTrackIdx + 1].howl.state() == 'unloaded')
            this.playlist.tracks[this.currentTrackIdx + 1].howl.load();
        }

        this.setDuration(this.getFormattedTime(track.duration));

        this.updateTrackPosition();

        this.interval = setInterval(this.updateTrackPosition.bind(this), 100);
      },

      onpause: () => {
        this.setIsPlayingDisplay(false);
        if (this.interval) clearInterval(this.interval);
      },

      onend: () => {
        if (this.currentTrackIdx == this.playlist.tracks.length - 1)
          this.resetAll();
        else
          this.playTrack(this.currentTrackIdx + 1, true);
      }
    });
  }

  playTrack(index, isSubsequentPlay = false) {
    this.playlist.tracks.forEach(track => {
      if (track.howl) {
        track.howl.stop();
      }
    });

    this.resetTrack();

    this.currentTrackIdx = index;

    const track = this.playlist.tracks[index];

    this.setTrackActive(track);

    if (!track.howl) {
      this.loadTrack(track, isSubsequentPlay);
    }

    track.howl.play();
  }

  setCurrentTrackActive() {
    if (!this.playlist || !this.playlist.tracks || this.playlist.tracks.length === 0 || !this.currentTrackIdx) return;
    const currentTrack = this.playlist.tracks[this.currentTrackIdx];
    this.setTrackActive(currentTrack);
  }

  setTrackActive(track) {
    this.setTrackTitle(track.title);

    document.querySelectorAll('.track.active').forEach(trackElement => {
      trackElement.classList.remove('active');
    });

    document.querySelectorAll(`.track[href="${track.url}"]`).forEach(trackElement => {
      trackElement.classList.add('active');
    });
  }
}
