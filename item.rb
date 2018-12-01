require 'json'

class Item
	attr_accessor :id , :sku , :description, :stock, :price


	def initialize(un_hash)
		@id = un_hash[:id]
		@sku = un_hash[:sku]
		@description= un_hash[:description]
		@stock= un_hash[:stock]
		@price= un_hash[:price]
	end

	def info_reducida
		#devuelve infomacion reducida del item, es decir, sin el stock ni el precio.
		{
			id:@id,
			sku:@sku,
			description:@description
		}
	end

	def info_completa
		#devuelve toda la informacion del item.
		{
			id:@id,
			sku:@sku,
			description:@description,
			stock:@stock,
			price:@price
		}
	end

	def modificar(un_hash)

		#modifica el item, unicamente en los campos que me hayan llegado como clave en el hash.
		#Los modifica con el valor que me llega como valor para cada clave.
        un_hash.each{ |clave, valor| self.send(clave + "=", valor)}
	end	

	def hay_stock(cant)

		#devuelve true, si el stock alcanza para satisfacer el pedido(cant).
		@stock >= cant
	end

	def descontar(cant)

		#resta al Stock la cantidad que se le vendio a un usuario.
		@stock = @stock - cant
	end


	def as_json(options={})
		{
			id: @id,
			sku: @sku,
			description: @description,
			stock: @stock,
			price: @price

		}
	end

	def to_json(*options)
		as_json(*options).to_json(*options)
	end


	#def to_json_pretty()
		#JSON.pretty_generate(self)
	#end

end