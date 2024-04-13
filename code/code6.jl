### A Pluto.jl notebook ###
# v0.19.38

using Markdown
using InteractiveUtils

# ╔═╡ 0ab2988c-8374-4970-934a-c1c3f9d3db51
using LinearAlgebra

# ╔═╡ 27cc1abd-2777-4f99-8ed3-0726de04fcd0
using Combinatorics

# ╔═╡ b843e11f-e205-404f-814a-00670e910336
# 6.1配列の2分探索

# ╔═╡ 14f55ef0-e693-11ee-28cb-47c3201aff09
#code6.1
function binary_search(a_sorted::AbstractVector, key)
    idx_s = firstindex(a_sorted)
    idx_e = lastindex(a_sorted)

    while idx_s <= idx_e
        idx_mid = idx_s + ((idx_e - idx_s) >>> 0x01)

        if a_sorted[idx_mid] == key
            return idx_mid
        elseif a_sorted[idx_mid] > key
            idx_e = idx_mid - 1
        else
            idx_s = idx_mid + 1
        end
    end

    return -1
end

# ╔═╡ 13f749d4-dcc5-4874-b9c2-2207f00f76fa
binary_search([5,13,14,18],15.0)

# ╔═╡ 1664ef62-ad40-486e-b88d-834e2225188a
# 6.2 lower_bound

# ╔═╡ c5dd8c1e-4735-4d0e-aabb-86456c7aec8d

function lower_bound(a_sorted::AbstractVector, key::Int)
	
	idx_s   = firstindex(a_sorted)
	idx_e   = lastindex(a_sorted)

	if a_sorted[idx_s]>key
		return -1
	else a_sorted[idx_e]<key
		return idx_e, a_sorted[idx_e]
	end
		
	@inbounds while((idx_s<=idx_e))
		idx_mid = idx_s + ((idx_e - idx_s) >>> 0x01)
		
		if a_sorted[idx_mid]==key
			return idx_mid, a_sorted[idx_mid]
		elseif a_sorted[idx_mid]>key
			idx_e = idx_mid-1
		else
			idx_s = idx_mid+1
		end

	end

	if a_sorted[idx_mid]>key
		idx_mid-=1
	end
	return idx_mid, a_sorted[idx_mid]
	
end

# ╔═╡ 22c8379d-0557-481c-afa3-48d8696d6dba
lower_bound([5,13,14,18],132)

# ╔═╡ 21f7141a-a4e6-482c-975c-7d8e79517be6
# 6.3一般化した二分探索法

# ╔═╡ a70fdd8b-6acc-4702-a933-a7b4b38e1505
function general_binary_search(
		judge_function::Function,
		left::T,	
		right::T, 
		delta::T) where T<:Real
	
	while(right-left>delta)
		mid::T = left + ((right-left)/2)
		if judge_function(mid)
			right = mid
		else
			left = mid
		end
	end
	return left
end

# ╔═╡ aee64bd2-dd97-48a0-b43d-634777c7c2ff
function general_binary_search(
		judge_function::Function,
		left::Int,	
		right::Int)
	
	while(right-left>1)
		mid = left + ((right-left)>>0x01)
		if judge_function(mid)
			right = mid
		else
			left = mid
		end
	end
	return left
end

# ╔═╡ 23019492-9d76-4e2e-b2b2-31f7064a6d27
function binary_serch2(a_sorted::AbstractVector{T}, key::T)where T<:Real

	if a_sorted[firstindex(a_sorted)]>key
		return -1
	end 
	
	if a_sorted[end]<=key
		return lastindex(a_sorted)
	end
	
		
	index = general_binary_search(
		x-> a_sorted[x] > key,
		firstindex(a_sorted),
		lastindex(a_sorted),
		1
	)
	
	return index
end

# ╔═╡ 55f07de6-4c6a-40a2-9080-0e0815e69b60
binary_serch2([5,13,14,18],18)

# ╔═╡ 4c130f21-a83f-4034-9989-4ebae6aa8464
# 6.3さらに一般化した二分探索法

# ╔═╡ 267dff19-c3c1-4c82-b1f9-4a962907d17c
begin
	ϵ=1e-8
	func = x -> (x-1.5)^2-3
	ans = general_binary_search(
			x-> func(x)>0,
			1.5,
			5.,
			ϵ
		)
	print(func(ans))
end

# ╔═╡ cfbf728c-e059-4fb1-a8ee-1dbd968c16e8
# 6.6年齢あてゲーム

# ╔═╡ a9635407-1c0f-48e1-b10d-fe08a3c43f08
begin
	a = [3,5,8,12,35]
	b = [1,4,10,24,28]
	K = 19
	local min_k = a[end]+b[end]
	
	for _a in a
		idx = general_binary_search(
			x-> _a+b[x]>K,
			firstindex(b),
			lastindex(b),
			1
		)
		if _a+b[idx]<K
			idx+=1
		end
		
		if min_k>(_a+b[idx])
			min_k = _a+b[idx]
		end
	end
	println(min_k)
end

# ╔═╡ e5fd6e25-c621-45a4-a06d-76e9a9ba9613
#6.7 射撃王

# ╔═╡ f05097d5-9ebd-427a-82d9-13a9cbff2cb6
begin 
	N = 3
	H = rand(1:10,N)
	S = rand(1:10,N)
end

# ╔═╡ 7df8f2ed-89a4-4b9a-863b-813a119439f1
function gun_shoot(H::AbstractVector{Int64}, S::AbstractVector{Int64})
	"""
	風船を割る高度の最大を最小にする。
	適当な高さｘをとり、その高さまでに割れるかを判定する。
	各風船で、高さｘに到達する時間は求められる（txi=(x-Hi)/Si）。
	しかし、１秒に１つの風船しか撃ち落とせない都合上、時間切れで撃ち落とせない可能性がある。
	時間切れになる前に各風船が撃ち落とせルカを判定するために、制限時間順に並べ、高度が肥えないかを判定する。
	
	"""
	# 1~N番目を順に撃ち落とした場合初期値をとする 
	shoot_time = collect(0:length(S)-1)
	
	arr_sorted = 1:maximum(H.+S.*shoot_time)
	
	idx_s    = firstindex(S)
	idx_end  = lastindex(S)
	function judge_func(x)
		sort_idx = sortperm((H.-x)./S)
		return maximum(H[sort_idx]+S[sort_idx].*shoot_time)<x
	end
	
	general_binary_search(
		judge_func,
		1,
		arr_sorted[end]
	)
	
end

# ╔═╡ 8f088aa6-2aa2-4c7a-9a21-56eeed9784e1
gun_shoot(H,S)

# ╔═╡ 6dedd298-502d-4d9e-9644-0af4bc7d0f92
begin
	base_time = collect(0:length(S)-1)
	min_cost = maximum(H+S.*base_time)
	println(H,S)
	for time in permutations(base_time, length(S))
		println(H+S.*time)
		min_cost = min(min_cost,maximum(H+S.*time))
	end
	print(min_cost)
end

# ╔═╡ e125ab0b-8733-4188-a816-b611a4883b9a


# ╔═╡ 17945d9e-23af-4cbc-9d1e-ae2ca662b3ad
H,S

# ╔═╡ 4aa0f038-f452-4d5e-8616-788353939ce5


# ╔═╡ 3da71730-b2c7-43d5-a4fc-67ab296f0b0d


# ╔═╡ e233e586-1c65-4e15-8fbf-25ab29167f5f


# ╔═╡ cd151f08-1a6e-4678-8ebb-6c5540363b83


# ╔═╡ 9d6b351a-76ad-4c8e-8962-d49568109af5


# ╔═╡ 665e3b00-d352-42d3-b7e8-9728fe295984


# ╔═╡ 67a50abf-f96a-4e5e-abe5-873c9f2cc8a2


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Combinatorics = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[compat]
Combinatorics = "~1.0.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.0"
manifest_format = "2.0"
project_hash = "ac80a5d41e33d4f3a6206aa84e474ab4529cce1d"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+2"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"
"""

# ╔═╡ Cell order:
# ╠═b843e11f-e205-404f-814a-00670e910336
# ╠═14f55ef0-e693-11ee-28cb-47c3201aff09
# ╠═13f749d4-dcc5-4874-b9c2-2207f00f76fa
# ╠═1664ef62-ad40-486e-b88d-834e2225188a
# ╠═c5dd8c1e-4735-4d0e-aabb-86456c7aec8d
# ╠═22c8379d-0557-481c-afa3-48d8696d6dba
# ╠═21f7141a-a4e6-482c-975c-7d8e79517be6
# ╠═a70fdd8b-6acc-4702-a933-a7b4b38e1505
# ╠═aee64bd2-dd97-48a0-b43d-634777c7c2ff
# ╠═23019492-9d76-4e2e-b2b2-31f7064a6d27
# ╠═55f07de6-4c6a-40a2-9080-0e0815e69b60
# ╠═4c130f21-a83f-4034-9989-4ebae6aa8464
# ╠═267dff19-c3c1-4c82-b1f9-4a962907d17c
# ╠═cfbf728c-e059-4fb1-a8ee-1dbd968c16e8
# ╠═a9635407-1c0f-48e1-b10d-fe08a3c43f08
# ╠═e5fd6e25-c621-45a4-a06d-76e9a9ba9613
# ╠═0ab2988c-8374-4970-934a-c1c3f9d3db51
# ╠═f05097d5-9ebd-427a-82d9-13a9cbff2cb6
# ╠═7df8f2ed-89a4-4b9a-863b-813a119439f1
# ╠═8f088aa6-2aa2-4c7a-9a21-56eeed9784e1
# ╠═27cc1abd-2777-4f99-8ed3-0726de04fcd0
# ╠═6dedd298-502d-4d9e-9644-0af4bc7d0f92
# ╠═e125ab0b-8733-4188-a816-b611a4883b9a
# ╠═17945d9e-23af-4cbc-9d1e-ae2ca662b3ad
# ╠═4aa0f038-f452-4d5e-8616-788353939ce5
# ╠═3da71730-b2c7-43d5-a4fc-67ab296f0b0d
# ╠═e233e586-1c65-4e15-8fbf-25ab29167f5f
# ╠═cd151f08-1a6e-4678-8ebb-6c5540363b83
# ╠═9d6b351a-76ad-4c8e-8962-d49568109af5
# ╠═665e3b00-d352-42d3-b7e8-9728fe295984
# ╠═67a50abf-f96a-4e5e-abe5-873c9f2cc8a2
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
