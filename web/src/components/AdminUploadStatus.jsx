import React from "react";
import { Progress } from "./ui/progress.jsx";

export function AdminUploadStatus({ status, lastLink }) {
  if (status.phase === "idle" && !lastLink) return null;

  return (
    <div className="mt-4 grid gap-2 rounded-md border border-border bg-background p-3 text-sm">
      {status.phase !== "idle" && (
        <>
          <div className="flex items-center justify-between gap-3">
            <span className={status.phase === "error" ? "text-red-600 dark:text-red-400" : "text-foreground"}>
              {status.message}
            </span>
            <span className="text-xs text-muted">{status.progress}%</span>
          </div>
          <Progress value={status.progress} />
        </>
      )}
      {lastLink && <p className="break-all text-xs text-muted">Stored as {lastLink}</p>}
    </div>
  );
}
