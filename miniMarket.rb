require 'bundler'
Bundler.require

require_relative 'item'
require_relative 'usuario'


before do
	content_type 'application/json'
end

#instaciacion
#Creo 2 items manuelamente y los incluyo en la coleccion "mis_items" que es la que voy a usar para almacenar los items
item1= Item.new({
	:id => 1,
	:sku => "300-JM-HTF",
	:description => "perfume de hombre",
	:stock => 30,
	:price => 700})

item2= Item.new({
	:id => 2,
	:sku => "100-ZX-CVB",
	:description => "reloj de mujer",
	:stock => 20,
	:price => 500})


mis_items= [item1, item2]

#De la misma forma que con los items creo 2 usuarios (a uno le creo carrito) y los agrego a "mis_usuarios"
usr1= Usuario.new({:nombre => "juanCarlos"})
usr1.crear_carrito
usr2= Usuario.new({:nombre => "LionelAndres"})

mis_usuarios= [usr1, usr2]



#implementacion
#Hay un ejemplo de como usar c/u al final.

get '/items.json' do 

	#Devuelve todos los items que haya en miniMarket, de forma reducida, es decir, sin stock ni precio

	result= mis_items.map{|x| x.info_reducida}
	JSON.dump(result)

	#ejemplo para pedir los items
	#curl -sSL -D - http://localhost:4567/items.json
end


get '/items/:id.json' do

	#devuelve la informacion completa de un item, que es solicitado por parametro con su id

	item_deseado= mis_items.detect{|item| item.id == params['id'].to_i}
    halt 404, "el id ingresado no existe" if item_deseado.nil?
	JSON.dump(item_deseado.info_completa)

	#ejemplo para pedir un item por id
	#curl -sSL -D - http://localhost:4567/items/1.json
end

post '/items.json' do

	#recibe parametros y crea un nuevo item para el minimercado
	#Se valida que lleguen TODOS los campos, en caso de faltar alguno devuelve 422
	#crea el item y lo almacena en la coleccion "mis_items"
    
    datos = JSON.parse request.body.read

    if datos["sku"].nil? || datos["description"].nil? || datos["stock"].nil? || datos["price"].nil?
    	halt 422, 'Faltan datos para crear el item'
    end

    item = Item.new({
    	:id => mis_items.length + 1,
  	    :sku => datos["sku"],
   	    :description => datos["description"],
        :stock => datos["stock"].to_i,
    	:price => datos["price"].to_f})

	mis_items.push(item)
    status 201
    JSON.dump(item.info_completa)

    #ejemplo agregar valido(con todos los campos, si falta alguno habra error)
    #curl -sSL -D - -X POST http://localhost:4567/items.json -H 'Content-Type: application/json' -d '{"sku": "12345-WH-XS", "description": "Women hoodie - White - XS", "price": 23.48, "stock": 8}'

end



put '/items/:id.json' do 
	
	#modifico el item que me llega con "id" con los valores de los parametros que me envian
	#Se valida que se envie un id y que ese item exista
	#Se valida que, al menos, me llegue un campo del item para modificar

	datos = JSON.parse request.body.read
	halt 422, 'falta el id del item' if params['id'].nil?
	item_elegido= mis_items.detect{|item| item.id == params["id"].to_i}
	if !item_elegido.nil?
	
		parametros = datos.select{|clave, valor| clave == "sku" || clave == "description" || clave == "stock" || clave == "price"}
		if !parametros.empty?
			item_elegido.modificar(parametros)
			JSON.dump(item_elegido.info_completa) 
		else 
			halt 422, 'No hay valores para modificar'
		end
	else
		halt 404, 'no existe el item a modificar'
	end

	#ejemplo de modificar un item por id
	#curl -sSL -D - -X PUT http://localhost:4567/items/1.json -H 'Content-Type: application/json' -d '{"sku": "12345-WH-XS", "description": "Women hoodie - White - XS", "price": 23.48, "stock": 8}'
end



get '/cart/:username.json' do

	#Devuelve los items en el carrito del usuario pasado por parámetro :username.
	#el monto total que lleva sumado para su compra, y la fecha en que se creó.
	#valida que el usuario exista y si no tiene carrito le crea uno

	usuario= mis_usuarios.detect{|usuario| usuario.nombre_usuario == params["username"]}
	if !usuario.nil?
		if !usuario.hay_carrito?
			usuario.crear_carrito
		end
		mostrar= usuario.imprimir
		JSON.dump(mostrar)
	else
		halt 404, 'el usuario no existe'
	end

	#ejemplo de obtener el carrito de usuario con "nombre de usuario" :username
	#curl -sSL -D - http://localhost:4567/cart/juanCarlos.json
end



put '/cart/:username.json' do 

	#Agrega un item al carrito
	#Se valida que se haya pasado un id como param.
	#Se valida que ese id exista en el minimercado
	#se valida que haya stock suficiente de ese item
	#se valida que el usuario exista y que tenga carrito
	#devuelvo el item que se agrego, indiferentemente el numero que se me pida agregar. 

	datos= JSON.parse request.body.read
	halt 422, 'falta el id del item' if datos['id'].nil?

	item_a_agregar= mis_items.detect{|item| item.id == datos["id"].to_i}
	if !item_a_agregar.nil?

		if item_a_agregar.hay_stock(datos['quantity'].to_i)
			item_a_agregar.descontar(datos['quantity'].to_i)
			usuario= mis_usuarios.detect{|usuario| usuario.nombre_usuario == params["username"]}
			if !usuario.nil?

				if !usuario.hay_carrito?
					usuario.crear_carrito
				end
				(datos['quantity'].to_i).times{usuario.usr_agregar_item(item_a_agregar)}
				JSON.dump(item_a_agregar)

			else
				halt 404, 'el usuario no existe'
			end
		else
			halt 404, 'no hay stock suficiente'
		end
	else
		halt 404, 'el item no existe' 
	end

	#ejemplo de agregar un/varios item/s al carrito de un usuario 
	#curl -sSL -D - -X PUT http://localhost:4567/cart/juanCarlos.json -d '{"id": "1", "quantity": 5}'
end



delete '/cart/:username/:item_id.json' do

	#Borra el/los item/s del carrito, con el id pasado por parametros
	#se valida que el usuario exista y que tenga carrito, tanto como la existencia de ese/esos item/s en dicho carrito
	#Devuelvo el item que fue eliminado, si habia varios objetos iguales, igualmente muestro 1.

	usuario= mis_usuarios.detect{|usuario| usuario.nombre_usuario == params["username"]}
	if !usuario.nil?
		if !usuario.hay_carrito?
			usuario.crear_carrito
		else
			item_a_borrar= usuario.tus_items.detect{|item| item.id == params['item_id'].to_i}
			halt 404, 'el item deseado no existe en ese carrito' if item_a_borrar.nil?
			usuario.borrar_del_carrito(item_a_borrar)
			JSON.dump(item_a_borrar)
		end
	end

	#ejemplo de borrar del carrito de un usuario uno/s elemento/s identificados por id
	# curl -d '' -X DELETE http://localhost:4567/cart/juanCarlos/1.json
end


