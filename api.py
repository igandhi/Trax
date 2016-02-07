from flask import Flask
from flask_restful import Resource, Api, reqparse
from flask.ext.mysql import MySQL

mysql = MySQL()
app = Flask(__name__)

app.config['MYSQL_DATABASE_USER'] = 'sql5105929'
app.config['MYSQL_DATABASE_PASSWORD'] = 'cbvZ6F2AgD'
app.config['MYSQL_DATABASE_DB'] = 'sql5105929'
app.config['MYSQL_DATABASE_HOST'] = 'sql5.freemysqlhosting.net'

mysql.init_app(app)
api = Api(app)

class GetAllTrains(Resource):
	def get(self):
		try:
			conn = mysql.connect()
			cursor = conn.cursor()
			cursor.callproc('getAllTrains')
			data = cursor.fetchall()

			trainList = []
			for item in data:
				i = {
					'trainId': item[0],
					'trainName': item[1]
				}
				trainList.append(i)

			return {'StatusCode': '200', 'data': trainList}

		except Exception as e:
			return {'error': str(e)}

class GetTrainStops(Resource):
	def get(self):
		try:
			#Parse the args
			parser = reqparse.RequestParser()
			parser.add_argument('id', type=str)
			args = parser.parse_args()

			_trainId = args['id']

			conn = mysql.connect()
			cursor = conn.cursor()
			cursor.callproc('getStopsForTrainId', (_trainId,))
			data = cursor.fetchall()

			stopList = []
			for item in data:
				i = {
					'stopId': item[0],
					'stopName': item[1]
				}
				stopList.append(i)

			return {'StatusCode': '200', 'data': stopList}

		except Exception as e:
			return {'error': str(e)}

class AddNewStatus(Resource):
	def get(self):
		try:
			#Parse the args
			parser = reqparse.RequestParser()
			parser.add_argument('stopId', type=str)
			parser.add_argument('delay', type=str)
			parser.add_argument('reason', type=str)
			args = parser.parse_args()

			_stopId = args['stopId']
			_delay = args['delay']
			_reason = args['reason']

			conn = mysql.connect()
			cursor = conn.cursor()
			cursor.callproc('addToHistory', (_stopId, _delay, _reason))
			data = cursor.fetchall()


			if len(data) is 0:
				conn.commit()
				return {'StatusCode': '200', 'Message': 'Status entered successfully'}
			else:
				return {'StatusCode': '1000', 'Message': str(data[0])}

		except Exception as e:
			return {'error': str(e)}

class GetIncidentsForTrainStop(Resource):
	def get(self):
		try:
			#Parse the args
			parser = reqparse.RequestParser()
			parser.add_argument('trainStopId', type=str)
			parser.add_argument('limit', type=str)
			args = parser.parse_args()

			_trainStopId = args['trainStopId']
			_limit = args['limit']

			conn = mysql.connect()
			cursor = conn.cursor()
			cursor.callproc('getHistoryForTrainStopId', (_trainStopId, _limit))
			data = cursor.fetchall()

			incidentList = []
			for item in data:
				i = {
					'timestamp': str(item[1]),
					'trainStopId': item[2],
					'timeDelayed': item[3],
					'reason': item[4]
				}
				incidentList.append(i)
			
			return {'StatusCode': '200', 'data': incidentList}

		except Exception as e:
			return {'error': str(e)}

api.add_resource(GetAllTrains, '/getAllTrains')
api.add_resource(GetTrainStops, '/getTrainStops')
api.add_resource(AddNewStatus, '/addNewStatus')
api.add_resource(GetIncidentsForTrainStop, '/getIncidentsForTrainStop')

if __name__ == '__main__':
	app.run(host='192.168.1.5', debug=True)