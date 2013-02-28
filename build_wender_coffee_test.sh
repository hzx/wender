export PYTHONPATH=../mutant:../riffler:$PYTHONPATH
python ../riffler/setup.py --task="test" --build_path="../build/wender_coffee_test" --test_suite="../client/wender/wender_coffee/test/test.module" --test_module="../client/wender/wender_coffee/wender.module"
