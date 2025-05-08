export interface Track {
    title: string;
    url: string;
    recordingUrl: string;

    howl: Howl | null;
    duration: number | null;
}

export interface Playlist {
    id: string;
    title: string;

    thumbnail: string;

    url: string;

    tracks: Track[];
}
