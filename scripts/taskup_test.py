import unittest
import tempfile
from contextlib import contextmanager

old_name = __name__
__name__ = "script"
exec(open("taskup.py").read())
__name__ = old_name


@contextmanager
def new_taskup(initial_content: str = ""):
    tf = tempfile.NamedTemporaryFile(delete_on_close=False)

    tf.write(bytes(initial_content, "utf8"))
    tf.close()

    yield (tf.name, TaskUp(tf.name))


class TestTaskUp(unittest.TestCase):
    def test_init(self):
        with new_taskup("active task\ninactive task") as (path, tu):
            self.assertEqual(len(tu.tasks), 2)
            self.assertEqual(tu.active_task, "active task")


if __name__ == "__main__":
    unittest.main()
