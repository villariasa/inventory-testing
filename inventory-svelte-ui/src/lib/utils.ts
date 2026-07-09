import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
import type { Component } from "svelte";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Utility types used by bits-ui component wrappers
export type WithElementRef<T, E extends HTMLElement = HTMLElement> = T & {
  ref?: E | null;
};

export type WithoutChildren<T> = Omit<T, "children">;
export type WithoutChild<T> = Omit<T, "child">;
export type WithoutChildrenOrChild<T> = Omit<T, "children" | "child">;
export type WithChild<T, C extends Record<string, any> = any> = T & { child?: Component<C> };
export type WithChildren<T> = T & { children?: import("svelte").Snippet };
