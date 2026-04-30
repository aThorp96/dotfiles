#!/usr/bin/env python3
import os
import argparse
import time


def value_or_stdin(value: str) -> str:
    if value == "-":
        value = input()
    return value


class TaskUp:
    path = os.path.join(os.environ.get('HOME'), ".config", "taskup.txt")

    active_task: str
    tasks: set[str]

    def __init__(self, path: str = ""):
        if path:
            self.path = path

        self.active_task, self.tasks = self._load()

    def _load(self) -> (str, set[str]):
        active_task = ""
        tasks = set()

        task_data = ""
        with open(self.path) as f:
            # leading whitespace indicates no current task
            task_data = str(f.read()).rstrip()

        raw_tasks = task_data.splitlines()
        tasks = {t.strip() for t in raw_tasks}

        if raw_tasks:
            active_task = raw_tasks[0].strip()
            if not active_task:
                active_task = ""

        return (active_task, tasks)

    def _save(self):
        task = self.active_task
        tasks = self.tasks

        if task and task in tasks:
            # remove the task to ensure it's at the top
            tasks.remove(task)

        task_list = list(tasks)
        task_list.insert(0, task)

        output = "\n".join(t for t in task_list)

        with open(self.path, "w") as f:
            f.write(output)

    def get_task(self) -> str:
        return self.active_task or ""

    def _set_task(self, desc: str):
        self.active_task = desc
        self.tasks.add(desc)

    def _add_task(self, desc: str):
        self.tasks.add(desc)

    def _complete_task(self):
        if self.active_task:
            self.tasks.remove(self.active_task)
            self.active_task = ""

    def _stop_task(self):
        if self.active_task:
            self.tasks.add(self.active_task)
            self.active_task = ""

    def _list_tasks(self, include_active: bool) -> list[str]:
        tasks = self.tasks
        if not include_active:
            tasks.remove(self.active_task)
        return [t for t in tasks if t]

    def render_task(self, max_width: int | None, scroll: bool, speed: int) -> str:
        desc = self.get_task()
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

    # Print the current task
    def show_task(self, args: argparse.Namespace):
        task = self.render_task(max_width=args.width, scroll=args.scroll, speed=args.scroll_speed)
        if task:
            print(task)
        else:
            print("(No active task)")

    # Set or create a task as the active task
    def set_task(self, args: argparse.Namespace):
        task = value_or_stdin(args.task)
        self._set_task(task)
        self._save()

    # Add a task without setting it as active
    def add_task(self, args: argparse.Namespace):
        task = value_or_stdin(args.task)
        self._add_task(task)
        self._save()

    # Clear the currently active task and remove it from the list of tasks
    def clear_task(self, args: argparse.Namespace):
        self._complete_task()
        self._save()

    # Remove a task from the list of tasks
    def remove_task(self, args: argparse.Namespace):
        task = value_or_stdin(args.task)
        if task == self.active_task:
            self.active_task = ""
        self.tasks.remove(task)

        self._save()

    # Clear the currently active task without deleting it from the list of tasks
    def stop_task(self, args: argparse.Namespace):
        self._stop_task()
        self._save()

    # Print the list of tasks
    def list_tasks(self, args: argparse.Namespace):
        inactive_only = args.inactive
        print("\n".join(self._list_tasks(include_active=not inactive_only)))
        self._save()


def __main__():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    taskup = TaskUp()

    set_task_parser = subparsers.add_parser("set", help="Set the current task")
    set_task_parser.add_argument("task")
    set_task_parser.set_defaults(func=taskup.set_task)

    set_task_parser = subparsers.add_parser("add", help="Add a new task")
    set_task_parser.add_argument("task")
    set_task_parser.set_defaults(func=taskup.add_task)

    subparsers.add_parser("clear", help="Stop and remove the current task").set_defaults(func=taskup.clear_task)
    subparsers.add_parser("stop", help="Stop the current task").set_defaults(func=taskup.stop_task)

    set_task_parser = subparsers.add_parser("remove", help="Remove a task")
    set_task_parser.add_argument("task")
    set_task_parser.set_defaults(func=taskup.remove_task)

    show_parser = subparsers.add_parser("show", help="Clear the current task")
    show_parser.add_argument("--width", type=int, help="character width to truncate response")
    show_parser.add_argument("--scroll", action='store_true', help="when used with --width, if the tsak description is longer than the max width, present an offset window of the description suitible for auto-refreshed views of the output")
    show_parser.add_argument("--scroll-speed", type=int, default=1, help="characters scrolled through each second")
    show_parser.set_defaults(func=taskup.show_task)

    set_task_parser = subparsers.add_parser("list", help="list tasks")
    set_task_parser.add_argument("--inactive", action="store_true", help="omit the active task from the list")
    set_task_parser.set_defaults(func=taskup.list_tasks)

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
