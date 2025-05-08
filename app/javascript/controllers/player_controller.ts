import { Controller } from "@hotwired/stimulus"
import { IsSlugFavourited } from "../db"
import { Howl, Howler } from 'howler'
import {Playlist, Track} from "../interfaces"

Howler.autoSuspend = false;

export default class PlayerController extends Controller<HTMLElement> {
  static targets = [
    "container", "currentTime", "duration", "progress", "trackTitle", "trackSubtitle", "isPlaying", "isPlayingMobile",
    "thumbnail", "mobilePlayer", "mobilePlayerThumbnail", "mobilePlayerBackdrop", "mobilePlayerTrackTitle", 
    "mobilePlayerTrackSubtitle", "mobilePlayerProgress", "mobilePlayerCurrentTime", "mobilePlayerDuration", 
    "mobilePlayerIsPlaying", "favouriteIcon", "mobilePlayerFavouriteIcon", "volumeControl", "isMuted"
  ];

  declare readonly containerTarget: HTMLElement;
  declare readonly currentTimeTarget: HTMLElement;
  declare readonly durationTarget: HTMLElement;
  declare readonly progressTarget: HTMLProgressElement;
  declare readonly trackTitleTarget: HTMLElement;
  declare readonly trackSubtitleTarget: HTMLElement;
  declare readonly isPlayingTarget: HTMLInputElement;
  declare readonly isPlayingMobileTarget: HTMLInputElement;
  declare readonly thumbnailTarget: HTMLImageElement;
  declare readonly mobilePlayerTarget: HTMLElement;
  declare readonly mobilePlayerThumbnailTarget: HTMLImageElement;
  declare readonly mobilePlayerBackdropTarget: HTMLImageElement;
  declare readonly mobilePlayerTrackTitleTarget: HTMLElement;
  declare readonly mobilePlayerTrackSubtitleTarget: HTMLElement;
  declare readonly mobilePlayerProgressTarget: HTMLProgressElement;
  declare readonly mobilePlayerCurrentTimeTarget: HTMLElement;
  declare readonly mobilePlayerDurationTarget: HTMLElement;
  declare readonly mobilePlayerIsPlayingTarget: HTMLInputElement;
  declare readonly favouriteIconTarget: HTMLElement;
  declare readonly mobilePlayerFavouriteIconTarget: HTMLElement;
  declare readonly volumeControlTarget: HTMLInputElement;
  declare readonly isMutedTarget: HTMLInputElement

  mobileBreakpointPx: number;
  iOS: boolean;

  playlist: Playlist | null;

  currentTrackIdx: number | null;
  interval: number | null; // Used to update timestamp and progress bar

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

  playPlaylist({ detail: { playlist, trackIdx } }: { detail: { playlist: Playlist; trackIdx: number } }) {
    if (this.playlist == null || this.playlist.id !== playlist.id) {
      this.resetAll();

      this.playlist = playlist;

      this.element.dataset.id = playlist.id;
      this.element.dataset.slug = this.getCurrentPlaylistSlug();

      this.containerTarget.classList.remove('invisible');
      this.containerTarget.classList.remove('opacity-0');

      this.setTrackSubtitle(playlist.title);
      this.setImageUrl(playlist.thumbnail);

      this.updateFavouriteIcon();
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
    window.Turbo.visit(this.playlist.tracks[this.currentTrackIdx].recordingUrl);
  }

  changeVolume(event: InputEvent) {
    const value = parseInt((event.currentTarget as HTMLInputElement).value) / 100;
    this.setVolume(value);
  }

  setVolume(value: number) {
    this.volumeControlTarget.value = (value * 100).toString();
    Howler.volume(value);
  }

  toggleFavourite() {
    const slug = this.getCurrentPlaylistSlug();
    this.dispatch('toggleFavourite', { detail: { slug } });
  }

  toggleMuted() {
    const isMuted = !this.isMutedTarget.checked;
    this.setIsMuted(isMuted);
  }

  setIsMuted(isMuted: boolean) {
    this.isMutedTarget.checked = isMuted;
    
    Howler.mute(isMuted);

    this.volumeControlTarget.disabled = isMuted;
    this.volumeControlTarget.classList.toggle('cursor-not-allowed', isMuted);
    this.volumeControlTarget.classList.toggle('opacity-50', isMuted);
  }

  // Internal

  // Called on initial page load only
  initialize() {
    this.mobileBreakpointPx = 1024;

    this.iOS = [
        'iPad Simulator',
        'iPhone Simulator',
        'iPod Simulator',
        'iPad',
        'iPhone',
        'iPod'
      ].includes(navigator.platform)
      // iPad on iOS 13 detection
      || (navigator.userAgent.includes("Mac") && "ontouchend" in document);

    this.resetAll();

    this.setVolume(1.0);

    navigator.mediaSession.setActionHandler("play", this.playPause.bind(this));
    navigator.mediaSession.setActionHandler("pause", this.playPause.bind(this));
    navigator.mediaSession.setActionHandler("stop", this.resetAll.bind(this));
  
    // navigator.mediaSession.setActionHandler("seekbackward", () => {});
    // navigator.mediaSession.setActionHandler("seekforward", () => {});
  
    navigator.mediaSession.setActionHandler("seekto", (x) => {
      const currentTrack = this.playlist[this.currentTrackIdx].track;
      if (currentTrack == null) return;
      currentTrack.seek(x.seekTime);
      this.updateTrackPosition();
    });
  
    navigator.mediaSession.setActionHandler("previoustrack", this.previousTrack.bind(this));
    navigator.mediaSession.setActionHandler("nexttrack", this.nextTrack.bind(this));  
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

    if (this.playlist && this.currentTrackIdx) {
      const currentTrack = this.playlist.tracks[this.currentTrackIdx].howl;

      if (currentTrack)
        currentTrack.stop();
    }
    
    this.currentTrackIdx = null;

    this.setIsPlayingDisplay(false);

    if (this.interval) {
      clearInterval(this.interval);
    }
  }

  getCurrentPlaylistSlug() {
    if (!this.playlist) return null;

    return this.playlist.url
      .split('/').pop()
      .split('?')[0]
      .split('#')[0];
  }

  async updateFavouriteIcon() {
    this.setFavouriteIcon(null);

    if (!this.playlist) return;

    const slug = this.getCurrentPlaylistSlug();
    const isFavourite = await IsSlugFavourited(slug);

    this.setFavouriteIcon(isFavourite);
  }

  setFavouriteIcon(isFavourite: boolean | null) {
    switch(isFavourite) {
      case true: {
        this.favouriteIconTarget.classList.add('active');
        this.mobilePlayerFavouriteIconTarget.classList.add('active');
        
        this.favouriteIconTarget.classList.remove('hidden');
        this.mobilePlayerFavouriteIconTarget.classList.remove('hidden');
        break;
      }

      case false: {
        this.favouriteIconTarget.classList.remove('active');
        this.mobilePlayerFavouriteIconTarget.classList.remove('active');
        
        this.favouriteIconTarget.classList.remove('hidden');
        this.mobilePlayerFavouriteIconTarget.classList.remove('hidden');
        break;
      }

      case null: {
        this.favouriteIconTarget.classList.add('hidden');
        this.mobilePlayerFavouriteIconTarget.classList.add('hidden');
        break;
      }
    }
  }

  setIsPlayingDisplay(isPlaying: boolean) {
    this.isPlayingTarget.checked = isPlaying;
    this.isPlayingMobileTarget.checked = isPlaying;
    this.mobilePlayerIsPlayingTarget.checked = isPlaying
  }

  setCurrentTime(time: string) {
    this.currentTimeTarget.textContent = time;
    this.mobilePlayerCurrentTimeTarget.textContent = time;
  }

  setDuration(time: string) {
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

  setTrackTitle(title: string) {
    this.trackTitleTarget.textContent = title;
    this.mobilePlayerTrackTitleTarget.textContent = title;
  }

  setTrackSubtitle(subtitle: string) {
    this.trackSubtitleTarget.textContent = subtitle;
    this.mobilePlayerTrackSubtitleTarget.textContent = subtitle;
  }

  resetAll() {
    this.resetTrack();

    if (this.playlist)
      this.playlist.tracks.forEach(track => {
        if (track.howl)
          track.howl.stop();
      });

    this.playlist = null;

    this.element.dataset.id = "";
    this.element.dataset.slug = "";

    this.setTrackSubtitle("");
    this.setImageUrl("");

    this.setFavouriteIcon(null);

    // Invisible is used to prevent click events, opacity-0 is used for fade in/out
    this.containerTarget.classList.add('invisible');
    this.containerTarget.classList.add('opacity-0');

    if (navigator.mediaSession)
  	  navigator.mediaSession.metadata = null;
  }

  setImageUrl(url: string) {
    this.thumbnailTarget.src = url;
    this.mobilePlayerThumbnailTarget.src = url;
    this.mobilePlayerBackdropTarget.src = url;//.style.backgroundImage = `url(${url})`;
  }

  getFormattedTime(seconds: number) {
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

  loadTrack(track: Track, isSubsequentPlay: boolean) {
    track.howl = new Howl({
      src: [track.url],
      preload: true,
      html5: !isSubsequentPlay,

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

        this.interval = window.setInterval(this.updateTrackPosition.bind(this), 100);
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

  playTrack(index: number, isSubsequentPlay = false) {
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

  setTrackActive(track: Track) {
    this.setTrackTitle(track.title);

    document.querySelectorAll('.track.active').forEach(trackElement => {
      trackElement.classList.remove('active');
    });

    document.querySelectorAll(`.track[href="${track.url}"]`).forEach(trackElement => {
      trackElement.classList.add('active');
    });

    if (navigator.mediaSession)
			navigator.mediaSession.metadata = new MediaMetadata({
				title: track.title,
				artist: "King Gizzard and the Lizard Wizard",
				album: this.playlist.title,
				artwork: [{ src: this.playlist.thumbnail }]
			});
  }
}
