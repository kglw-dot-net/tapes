import { Controller } from "@hotwired/stimulus"
import { Howl, Howler } from 'howler'

export default class extends Controller {
  static targets = ["container", "currentTime", "duration", "progress", "trackTitle", "trackSubtitle", "isPlaying", "thumbnail"];

  // Events

  playPlaylist({ detail: { playlist, trackIdx } }) {
    if (this.playlist.id !== playlist.id) {
      this.resetTrack();

      this.playlist = playlist;

      this.containerTarget.classList.remove('invisible');
      this.containerTarget.classList.remove('opacity-0');

      this.trackSubtitleTarget.textContent = `${this.playlist.title}`;
      this.thumbnailTarget.src = this.playlist.thumbnail;
    }

    this.playTrack(trackIdx);
  }

  seek(event) {
    const currentTrack = this.playlist.tracks[this.currentTrackIdx].howl;

    if (currentTrack == null) return;

    const progressWidth = this.progressTarget.clientWidth;
    const mouseX = event.clientX - this.progressTarget.getBoundingClientRect().left;

    const percent = mouseX / progressWidth;

    currentTrack.seek(this.playlist.tracks[this.currentTrackIdx].duration * percent);

    this.updateTrackPosition();
  }

  playPause() {
    const isPlaying = (this.isPlayingTarget.checked = !this.isPlayingTarget.checked);
    const currentTrack = this.playlist.tracks[this.currentTrackIdx].howl;

    if (currentTrack == null) return;

    if (isPlaying && !currentTrack.playing())
      currentTrack.play();

    if (!isPlaying && currentTrack.playing())
      currentTrack.pause();
  }

  // Internal

  // Called on initial page load only
  initialize() {
    this.iOS = false;
    this.resetAll();
  }

  // Called on all page loads
  connect() {
    this.setCurrentTrackActive();
  }

  resetTrack() {
    this.progressTarget.removeAttribute("value");
    this.progressTarget.classList.remove('progress-primary');

    this.currentTimeTarget.textContent = "0:00";
    this.durationTarget.textContent = "0:00";

    this.trackTitleTarget.textContent = "";

    this.currentTrackIdx = null;

    this.isPlayingTarget.checked = false;

    if (this.interval) {
      clearInterval(this.interval);
    }
  }

  resetAll() {
    this.resetTrack();

    this.playlist = {};

    this.trackSubtitleTarget.textContent = "";
    this.thumbnailTarget.src = "";

    // Invisible is used to prevent click events, opacity-0 is used for fade in/out
    this.containerTarget.classList.add('invisible');
    this.containerTarget.classList.add('opacity-0');
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

    this.currentTimeTarget.textContent = this.getFormattedTime(currentTime);

    const percentPlayed = currentTime / this.playlist.tracks[this.currentTrackIdx].duration;

    this.progressTarget.setAttribute("value", percentPlayed * 100);

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
        // TODO: Reimplement play button state change visibility

        this.isPlayingTarget.checked = true;

        // TODO: Reimplement this
        // If there is a next track, load it
        // if (currentTrackIdx != playlist.length - 1) {
        //   if (playlist[currentTrackIdx + 1].track == null)
        //     loadTrack(currentTrackIdx + 1, true);

        //   if (playlist[currentTrackIdx + 1].track.state() == 'unloaded')
        //     playlist[currentTrackIdx + 1].track.load();
        // }

        this.durationTarget.textContent = this.getFormattedTime(track.duration);

        this.updateTrackPosition();

        this.progressTarget.classList.add('progress-primary');

        this.interval = setInterval(this.updateTrackPosition.bind(this), 100);
      },

      onpause: () => {
        this.isPlayingTarget.checked = false;
        if (this.interval) clearInterval(this.interval);
      },

      onend: () => {
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
    this.trackTitleTarget.textContent = track.title;

    document.querySelectorAll('.track.active').forEach(trackElement => {
      trackElement.classList.remove('active');
    });

    document.querySelectorAll(`.track[href="${track.url}"]`).forEach(trackElement => {
      trackElement.classList.add('active');
    });
  }
}
