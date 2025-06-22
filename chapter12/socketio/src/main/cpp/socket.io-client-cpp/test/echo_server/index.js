var port = 3000;

var io = require('socket.io')().listen(port);
console.info("Listening on port " + port);

/* Socket.IO events */
io.on("connection", function(socket){
    console.info("new connection");
    socket.on('test_text', (...args) => {
        console.info("test text event received.", args);
    });

    socket.on('test_binary', (...args) => {
        console.info("test binary event received", args);
      if(args[0] instanceof Buffer)
      {
        console.info("test binary event received,binary length:"+ args[0].length);
      }
    });

    socket.on('test ack',function()
    {
       var args =Array.prototype.slice.call(arguments);
      if('object' == typeof args[0])
      {
        console.info("test combo received,object:");
        console.info(JSON.stringify(args[0]));
      }
      if(args.length>1 && 'function' == typeof args[args.length - 1])
      {
        console.info('need ack for test combo');
        var fn = args[args.length - 1];
        fn('Got bin length:' + args[0].bin.length);//invoke ack callback function.
      }
    });

  });