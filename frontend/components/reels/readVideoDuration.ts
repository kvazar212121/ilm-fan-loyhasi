export function readVideoDuration(file: File): Promise<number> {
  return new Promise((resolve, reject) => {
    const video = document.createElement("video");
    video.preload = "metadata";

    const url = URL.createObjectURL(file);
    video.onloadedmetadata = () => {
      URL.revokeObjectURL(url);
      if (!Number.isFinite(video.duration)) {
        reject(new Error("Video davomiyligini o‘qib bo‘lmadi."));
        return;
      }
      resolve(video.duration);
    };
    video.onerror = () => {
      URL.revokeObjectURL(url);
      reject(new Error("Video faylini o‘qib bo‘lmadi."));
    };
    video.src = url;
  });
}