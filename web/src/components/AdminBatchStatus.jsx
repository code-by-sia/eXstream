import React from "react";
import { Check, Loader, X } from "lucide-react";

const icons = { done: Check, error: X };

export function AdminBatchStatus({ items, error }) {
  if (error) return <p className="upload-message-error">{error}</p>;
  if (!items.length) return null;

  return (
    <ul className="batch-status">
      {items.map((item, index) => {
        const Icon = icons[item.status] || Loader;
        return (
          <li key={index} className={`batch-row batch-${item.status}`}>
            <Icon className="icon-sm batch-icon" />
            <span className="batch-name">{item.title || item.name}</span>
            <span className="batch-message">{item.message}</span>
          </li>
        );
      })}
    </ul>
  );
}
