class Carrito
	attr_accessor :mis_items_personales, :fecha_creacion

	def initialize()
	#(*items) para recibir varios params
		@mis_items_personales=[]
		@fecha_creacion= Date.today 
		#items.each{|item| @mis_items_personales.push(item)}
	end


	def agregar_item(un_item)

		#agrega "un item" a su coleccion 
		@mis_items_personales.push(un_item)
	end


	def monto_total

		#obtiene el monto total en precios de items
		@mis_items_personales.inject(0){|sum, item| sum + item.precio}
	end 


	def borrar_item(item_a_borrar)

		#elimina "item_a_borrar" de la coleccion
		#item puede ser tanto UN item, como varios.
		#varios en caso de que cuando se hace el put se haya puesto una cantidad mayor a 1.
		@mis_items_personales.delete_if { |item| item == item_a_borrar }
	end
end