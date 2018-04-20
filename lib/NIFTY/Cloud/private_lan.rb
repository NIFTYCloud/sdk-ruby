# coding: utf-8
module NIFTY
  module Cloud
    class Base < NIFTY::Base
      PVLAN_FILTER_NAME = ['availabilityZone', 'availability-zone', 'cidrBlock', 'cidr', 'cidr-block', 'state', 'network-id', 'private-lan-name', 'accountingType', 'description']
      PVLAN_MODIFY_ATTRIBUTE = ['privateLanName', 'cidrBlock', 'accountingType', 'description']
      PVLAN_COURSE = ['1', '2']

      # API「NiftyCreatePrivateLan」を実行し、プライベート LAN を新規作成します。
      #
      #  @option options [String] :private_lan_name   プライベート LAN 名
      #  @option options [String] :cidr_block         プライベート LAN の CIDR (必須)
      #  @option options [String] :availability_zone  ゾーン情報
      #  @option options [String] :accounting_type    利用料金タイプ
      #  @option options [String] :description        プライベート LAN のメモ
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   nifty_create_private_lan(:private_lan_name => 'pvlan01', :cidr_block => '192.168.10.0/24')
      #
      def nifty_create_private_lan( options={} )
        raise ArgumentError, "No :cidr_block provided." if blank?(options[:cidr_block])
        begin IPAddr.new(options[:cidr_block].to_s) rescue raise ArgumentError, "Invalid :cidr_block provided." end

        params = {'Action' => 'NiftyCreatePrivateLan'}
        params.merge!(opts_to_prms(options, [:private_lan_name, :cidr_block, :accounting_type, :description, :availability_zone]))

        return response_generator(params)
      end

      # API「NiftyDeletePrivateLan」を実行し、指定したプライベート LAN を削除します。
      #
      #  @option options [String] :network_id         ネットワークユニークID (:private_lan_name とどちらか必須)
      #  @option options [String] :private_lan_name   プライベートLAN名 (:network_id とどちらか必須)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   nifty_delete_security_group(:private_lan_name => 'pvlan01')
      #
      def nifty_delete_private_lan( options={} )
        raise ArgumentError, ":network_id or :private_lan_name must be provided." if blank?(options[:network_id]) && blank?(options[:private_lan_name])

        params = {
          'Action' => 'NiftyDeletePrivateLan',
          'NetworkId' => options[:network_id].to_s,
          'PrivateLanName' => options[:private_lan_name].to_s
        }

        return response_generator(params)
      end

      # API「NiftyDescribePrivateLans」を実行し、指定したプライベート LAN の設定情報を取得します。
      #
      #  @option options [String] :network_id        ネットワークユニークID
      #  @option options [String] :private_lan_name  プライベートLAN名
      #  @option options [Array<Hash>] :filter    フィルター設定
      #   <Hash> options  [String] 絞り込み条件の項目名
      #                    許可値: availability-zone | cidr-block | state | network-id | private-lan-name | accountingType | description
      #                   [String] 絞り込み条件の値 （前方一致）
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   nifty_describe_private_lans(:network_id => 'pvlan01')
      #
      def nifty_describe_private_lans( options={} )
        [options[:network_id]].flatten.each do |e|
          raise ArgumentError, "Invalid :network_id provided." unless ALPHANUMERIC =~ options[:network_id].to_s
        end unless blank?(options[:network_id])
        [options[:private_lan_name]].flatten.each do |e|
          raise ArgumentError, "Invalid :private_lan_name provided." unless ALPHANUMERIC =~ options[:private_lan_name].to_s
        end unless blank?(options[:private_lan_name])

        params = {'Action' => 'NiftyDescribePrivateLans'}
        params.merge!(pathlist("NetworkId", options[:network_id]))
        params.merge!(pathlist("PrivateLanName", options[:private_lan_name]))

        unless blank?(options[:filter])
          [options[:filter]].flatten.each do |opt|
            raise ArgumentError, "expected each element of arr_of_hashes to be a Hash" unless opt.is_a?(Hash)
            raise ArgumentError, "Invalid :name provided." unless blank?(opt[:name]) || PVLAN_FILTER_NAME.include?(opt[:name].to_s)
            opt[:value] = [opt[:value]].flatten unless blank?(opt[:value])
          end
          params.merge!(pathhashlist('Filter', options[:filter], {:name => 'Name', :value => 'Value'}))
        end
        return response_generator(params)
      end

      # API「NiftyModifyPrivateLanAttribute」を実行し、指定したプライベート LAN の詳細情報を更新します。1 回のリクエストで、1 つのサーバーの情報を更新できます。
      #
      #  @option options [String] :network_id          ネットワークユニークID (必須)
      #  @option options [String] :private_lan_name    プライベートLAN名 (必須)
      #  @option options [String] :attribute           更新対象の項目名 (必須)
      #   許可値: privateLanName (プライベートLAN名を更新) | cidrBlock (プライベートLANのCIDRを更新) | accountingType(利用料金タイプを更新) | description (メモ情報を更新)
      #
      #  @option options [String] :value               更新値 (必須)
      #   許可値: (:attribute= accountingType) 1(月額課金) | 2(従量課金)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   nifty_modify_private_lan_attribute(:private_lan_name => 'pvlan01', :attribute => 'accountingType', :value => '1')
      #
      def nifty_modify_private_lan_attribute( options = {} )
        raise ArgumentError, ":network_id or :private_lan_name must be provided." if blank?(options[:network_id]) && blank?(options[:private_lan_name])
        raise ArgumentError, "No :attribute provided." if blank?(options[:attribute])
        raise ArgumentError, "Invalid :attribute provided." unless PVLAN_MODIFY_ATTRIBUTE.include?(options[:attribute].to_s)
        raise ArgumentError, "No :value provided." if blank?(options[:value])
        raise ArgumentError, "Invalid :value provided." if options[:attribute] == 'accountingType' && !PVLAN_COURSE.include?(options[:value].to_s)
        begin IPAddr.new(options[:value].to_s) rescue raise ArgumentError, "Invalid :cidr_block provided." end if options[:attribute] == 'cidrBlock'

        params = {'Action' => 'NiftyModifyPrivateLanAttribute'}
        params.merge!(opts_to_prms(options, [:network_id, :private_lan_name, :attribute, :value]))

        return response_generator(params)
      end

    end
  end
end

