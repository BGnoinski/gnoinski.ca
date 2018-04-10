from subprocess import call, check_output
import argparse
import glob
import os
import shutil

def clean():
    container = check_output(['docker', 'ps', '-af', 'name=gnoinski', '-q']).decode().rstrip("\n")
    if not container:
        print('There is no container currently')
        pass
    else:
        actions = ['kill', 'rm']
        for action in actions:
            command = ['docker', action , container]
            print('%s %s' % (action, container))
            call(command)

    output_files = glob.glob('output/*')
    for file_to_remove in output_files:
        try:
            os.remove(file_to_remove)
        except IsADirectoryError:
            shutil.rmtree(file_to_remove)


def build():
    pass


def dev():
    pass


def upload():
    pass


def main():
    clean()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Replace your make file here.')
    parser.add_argument('--clean')
    parser.add_argument('--build')
    parser.add_argument('--dev')
    parser.add_argument('--upload')
    args = parser.parse_args()

    main()
