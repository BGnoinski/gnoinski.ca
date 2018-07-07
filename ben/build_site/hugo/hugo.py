#!/usr/bin/python3
from subprocess import call, check_output
import argparse
import glob
import os
import shutil


def clean():
    container = check_output(['docker', 'ps', '-af', 'name=hugo', '-q']).decode().rstrip("\n")
    if not container:
        print('There is no container currently')
        pass
    else:
        actions = ['kill', 'rm']
        for action in actions:
            command = ['docker', action , container]
            print('%s %s' % (action, container))
            call(command)

    output_files = glob.glob('ben.gnoinski.ca/public/*')
    for file_to_remove in output_files:
        try:
            os.remove(file_to_remove)
        except IsADirectoryError:
            shutil.rmtree(file_to_remove)


def build():
    call(['docker',  'build', '-t', 'hugo:latest', '.'])


def dev():
    clean()
    build()
    call(['docker', 'run', '-td', '-p', '1313:1313', '-v', '%s:/hugo' % os.getcwd(), '--name', 'hugodev', '-u', os.getenv('USER'), 'hugo:latest', '/usr/bin/hugo', 'server', '-D', '--bind', '0.0.0.0', '--config', 'configDev.toml']) 


def publish():
    clean()
    build()
    call(['docker', 'run', '-v', '%s:/hugo' % os.getcwd(), '--name', 'hugodev', '-u', os.getenv('USER'), 'hugo:latest', '/usr/bin/hugo', ]) 


def upload():
   publish()
   call(['aws', 's3', 'sync', '--delete', '%s/ben.gnoinski.ca/public' % os.getcwd(), 's3://ben.gnoinski.ca'])
   call(['aws', 'cloudfront', 'create-invalidation', '--distribution-id', 'EW7T5A29H3R3J', '--paths', '/*'])


def main(args):
    FUNCTION_MAP[args.action]()


if __name__ == '__main__':
    FUNCTION_MAP = {'clean': clean,
                    'build': build,
                    'dev': dev,
                    'upload': upload,
                    'publish': publish}
    parser = argparse.ArgumentParser(description='Replace your make file here.')
    parser.add_argument('action', choices=FUNCTION_MAP, help='usage, python3 newmake.py build|dev|clean|upload|publish')
    args = parser.parse_args()

    main(args)
