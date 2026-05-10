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
    color: string;

    showTitle: string;
    venueName: string;
    city: string;
    date: string;

    duration: number;

    url: string;

    tracks: Track[];
}
