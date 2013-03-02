export PYTHONPATH=../mutant:../riffler:$PYTHONPATH
python ../riffler/setup.py --task="test" --build_path="../build/wender_coffee_test" --test_suite="../wender/client/wender_coffee/test/test.module" --test_module="../wender/client/wender_coffee/wender.module"
