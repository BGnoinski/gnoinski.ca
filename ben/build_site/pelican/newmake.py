#!/usr/bin/python3
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
    call(['docker',  'build', '-t', 'gnoinski.ca:latest', '.'])


def dev():
    clean()
    build()
    call(['docker', 'run', '-td', '-p', '8080:8080', '-v', '%s:/site' % os.getcwd(), '--name', 'bengnoinskidev', '-u', os.getenv('USER'), 'gnoinski.ca:latest', '/bin/bash', '-c', '/site/develop_server.sh start 8080 && sleep 1d']) 


def upload():
   call(['aws', 's3', 'sync', '--delete', '%s/output' % os.getcwd(), 's3://ben.gnoinski.ca'])
   call(['aws', 'cloudfront', 'create-invalidation', '--distribution-id', 'EW7T5A29H3R3J', '--paths', '/*'])


def main(args):
    FUNCTION_MAP[args.action]()


if __name__ == '__main__':
    FUNCTION_MAP = {'clean': clean,
                    'build': build,
                    'dev': dev,
                    'upload': upload}
    parser = argparse.ArgumentParser(description='Replace your make file here.')
    parser.add_argument('action', choices=FUNCTION_MAP, help='usage, python3 newmake.py build|dev|clean|upload')
    args = parser.parse_args()

    main(args)
