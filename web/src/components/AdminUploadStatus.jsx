import React from "react";
import { Progress } from "./ui/progress.jsx";

export function AdminUploadStatus({ status, lastLink }) {
  if (status.phase === "idle" && !lastLink) return null;

  return (
    <div className="upload-status">
      {status.phase !== "idle" && (
        <>
          <div className="upload-status-row">
            <span className={status.phase === "error" ? "upload-message-error" : "upload-message"}>
              {status.message}
            </span>
            <span className="upload-progress-text">{status.progress}%</span>
          </div>
          <Progress value={status.progress} />
        </>
      )}
      {lastLink && <p className="upload-link">Stored as {lastLink}</p>}
    </div>
  );
}
