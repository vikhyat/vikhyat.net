SERVER=106.187.44.241

#echo "============= Compiling site... ========================================="
#cd web/
#rake clean
#rake
#cd ..

echo "\n\n"
echo "============= Copying source... ========================================="
rsync -e ssh -avl --progress --delete --exclude "web/Application/tmp/" --exclude "web/Application/log" . root@$SERVER:/var/vikhyat

echo "\n\n"
echo "============= Running babushka... ======================================="
ssh root@$SERVER -t "bash -l -c 'cd /var/vikhyat && babushka meet --no-color vikhyat-net'"

echo "\n\n"
echo "============= Restarting application... =================================="
ssh root@$SERVER -t "bash -l -c 'cd /var/vikhyat/web/Application && bundle exec thin restart --all /etc/thin'" | egrep -v '^[[:space:]]*$'
