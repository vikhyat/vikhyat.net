SERVER=106.187.44.241

echo "============= Compiling site... ========================================="
cd web/
rake clean
rake
cd ..

echo "\n\n"
echo "============= Copying source... ========================================="
rsync -e ssh -avl --delete --progress . root@$SERVER:/var/vikhyat

echo "\n\n"
echo "============= Running babushka... ======================================="
ssh root@$SERVER -t "bash -l -c 'cd /var/vikhyat && babushka meet --no-color vikhyat-net'"
