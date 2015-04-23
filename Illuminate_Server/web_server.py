import RPi.GPIO as GPIO
import web
import json

#import signal
#import sys
#
#def signal_handler(signal, frame):
#    print "\nCleaning up pins."
#    GPIO.cleanup()
#    sys.exit(0)
#signal.signal(signal.SIGINT, signal_handler)

urls = (
        '/state', 'state',
        '/switch', 'switch'
)

web.config.debug=False

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(17, GPIO.OUT)

class state:
    def GET(self):
        state = None
        if GPIO.input(17):
            state = { 'state' : 'on' }
        else:
            state = { 'state' : 'off' }
        
        web.header('Content-Type', 'application/json')
        
        print 'Reply:', state
        return json.dumps(state)
        
        #render = web.template.render('templates/')
        #return render.state(state)

class switch:
    def GET(self):
        query = web.input(direction=None)
        print query
        if query.direction == 'on':
            GPIO.output(17,1)
        elif query.direction == 'off':
            GPIO.output(17,0)

        web.header('Content-Type', 'application/json')
    
        switch = { 'switch' : query.direction }
        print 'Reply:', switch
        return json.dumps(switch)

        #render = web.template.render('templates/')
        #return render.switch(query.direction)

if __name__ == "__main__":
    app = web.application(urls, globals())
    app.run()

#http://192.168.1.42:8080/state
#http://192.168.1.42:8080/switch?direction=on
#http://192.168.1.42:8080/switch?direction=off
