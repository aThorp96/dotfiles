#!/usr/bin/env python3

import os
import argparse
from pydantic import BaseModel
import time


class Task(BaseModel):
    description: str


class TaskUp:
    path = os.path.join(os.environ.get('HOME'), ".config", "taskup.json")

    def __init__(self, path: str = ""):
        if path:
            self.path = path

    def get_task(self) -> Task:
        with open(self.path) as f:
            return Task.model_validate_json(f.read())

    def _set_task(self, desc: str):
        with open(self.path, "w") as f:
            f.write(Task(description=desc).model_dump_json())

    def render_task(self, max_width: int | None, scroll: bool, speed: int) -> str:
        desc = self.get_task().description
        if max_width and len(desc) > max_width:
            if not scroll:
                return desc[:max_width]
            else:
                factor = 1000000000
                if speed != 0:
                    factor = factor / speed
                offset = int(time.time_ns() / factor) % len(desc)
                substr = desc[offset:offset+max_width]
                remainder = max_width - len(substr)
                if remainder > 0:
                    substr += " " + desc[:remainder-1]
                return substr
        else:
            return desc

    @classmethod
    def show_task(cls, args: argparse.Namespace):
        task = cls().render_task(max_width=args.width, scroll=args.scroll, speed=args.scroll_speed)
        if task:
            print(task)
        else:
            print("(No active task)")

    @classmethod
    def set_task(cls, args: argparse.Namespace):
        cls()._set_task(args.task)
        cls.show_task(args)

    @classmethod
    def clear_task(cls, args: argparse.Namespace):
        cls()._set_task("")


def __main__():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    set_task_parser = subparsers.add_parser("set", help="Set the current task")
    set_task_parser.add_argument("task")
    set_task_parser.set_defaults(func=TaskUp.set_task)

    subparsers.add_parser("clear", help="Clear the current task").set_defaults(func=TaskUp.clear_task)

    show_parser = subparsers.add_parser("show", help="Clear the current task")
    show_parser.add_argument("--width", type=int, help="character width to truncate response")
    show_parser.add_argument("--scroll", action='store_true', help="when used with --width, if the tsak description is longer than the max width, present an offset window of the description suitible for auto-refreshed views of the output")
    show_parser.add_argument("--scroll-speed", type=int, default=1, help="characters scrolled through each second")
    show_parser.set_defaults(func=TaskUp.show_task)

    parsed = parser.parse_args()

    if hasattr(parsed, "func"):
        try:
            parsed.func(parsed)
        except Exception as e:
            print(f"Error: {e}")
            print(f"---\n{parser.format_help()}")
    else:
        print(parser.format_help())


if __name__ == "__main__":
    __main__()
